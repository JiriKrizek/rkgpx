# Parse commandline arguments and prepare files.
class Commandline
  attr_reader :edit_in_place, :merge, :files, :threshold

  public
    def initialize(given_arguments, log)
      @arguments = given_arguments
      @log = log

      @edit_in_place=false
      @merge=true
      @mset=false
      @expecting_threshold=false
      @threshold=30.0

      @files = []

      @print_help = false
    end

    def to_s
      object_status="Arguments: "+@arguments.join(" ")+"; "
      object_status+="files.count: #{@files.count}; "
      object_status+="merge: #{@merge}; "
      object_status+="edit_in_place: #{@edit_in_place}; "
      object_status+="threshold: #{threshold}; "
    end

    def parse
      # Process all arguments
      @arguments.each do |arg|
        if arg.start_with?("-")
          parse_switch arg
        else
          parse_arg arg
        end
      end

      # Check validity of arguments
      if @files.count == 0
        puts "ERROR: No input files specified."
        print_help
      end

      filter_invalid_files
    end

  private
    # Parse switch argument and set relevant flag variable
    def parse_switch(arg)
      argument = arg[1..-1].downcase

      # Version
      if argument =~ /^(v|-version)$/
        print_version
      end

      # Argument output_dir
      if argument.eql?("m")
        @merge = true
        @edit_in_place=false unless @mset==true
        @mset=true
      end

      # In place
      if argument.eql?("i")
        @edit_in_place=true
        @merge=false unless @mset==true
      end

      # Argument threshold
      if argument.eql?("t")
        if @expecting_threshold==false
          @expecting_threshold=true
        else
          puts "Argument threshold expected after -t switch\n"
          print_help
        end
      end

      # Arguments -H, -h, --help, -help...
      if argument =~ /^-*h+(elp)*$/i
        print_help
      end

    end

    # Parse argument
    def parse_arg(arg)
      @files << arg unless arg.empty?

      if @expecting_threshold
        begin
          @threshold = Float(arg)
        rescue
          print_help
        ensure
          @expecting_threshold=false
        end

      end
    end

    # Print usage and exits program
    def print_help
      puts "Usage:
      \t./#{$PROGRAM_NAME} file.gpx [file2.gpx ...] -i|-m|--help\n
      \t\t#{$PROGRAM_NAME}\t - name of script
      \t\tfile.gpx file2.gpx\t - one or more file names to fix
      \t\t-i\t - fix files 'in place'
      \t\t-m\t - merge to one gpx file, if tracks are continous (see -t switch) (default)
      \t\t-t NUM - treshhold for merge tolerance in meters (default 30 meters)
      \t\t--help\t - print usage"
      exit 1
    end

    # Print version and exits program
    def print_version
      version="unknown"
      version_file="lib/version.rb"

      if File.exist?(version_file)
        require_relative "version.rb"
        version=get_version
      end

      puts "Version: #{version}\n"
      exit 2
    end

    # Remove non existing files and notify users
    def filter_invalid_files
      real_files=[]
      @files.each do |file|
        if @edit_in_place
          if File.writable?(file)
            real_files << file 
          else
            puts "ERROR: File #{file} is not writable, ignoring."
          end
        else
          if File.readable?(file)
            real_files << file 
          else
            puts "ERROR: File #{file} is not readable, ignoring."
          end
        end
      end
      @files=real_files
    end
end
