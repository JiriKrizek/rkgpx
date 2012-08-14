# Parse commandline arguments and prepare files.
class Commandline
  attr_reader :edit_in_place, :output_dir, :files

  public
    def initialize(given_arguments)
      @arguments = given_arguments

      @edit_in_place=false
      @expecting_dir=false
      @output_dir=nil

      @files = []

      @print_help = false
    end

    def to_s
      object_status="Arguments: "+@arguments.join(" ")+"; "
      object_status+="files.count: #{@files.count}; "
      object_status+="output_dir: #{@output_dir}; "
      object_status+="edit_in_place: #{@edit_in_place}; "
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

      if (@expecting_dir == true && @output_dir.nil?)
        puts "ERROR: Expecting argument for '-o' switch"
        print_help
      end

      if @edit_in_place && @output_dir
        puts "Could not use both '-i' and '-o' switch.\n"
        print_help
      end

      filter_invalid_files

      # Create directory if not already exist
      if @files.size
        create_dir(@output_dir) if @output_dir
      end
    end

  private
    # Parse switch argument and set relevant flag variable
    def parse_switch(arg)
      argument = arg[1..-1].downcase

      # Version
      if argument =~ /^(v|-version)$/
        print_version
      end

      # In place
      if argument.eql?("i")
        if ( @edit_in_place || @expecting_dir )
          puts "Invalid usage of '-i' switch."
          print_help
        else
          puts "arg eql i"
          @edit_in_place=true
        end
      end

      # Argument output_dir
      if argument.eql?("o")
        if @expecting_dir==false
          @expecting_dir=true
        else
          puts "Argument DIR expected after '-o' switch\n"
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
      if @expecting_dir
        @output_dir=arg
        @expecting_dir=false
      else
        @files << arg unless arg.empty?
      end
    end

    # Print usage and exits program
    def print_help
      puts "Usage:
      \t./#{$PROGRAM_NAME} file.gpx [file2.gpx ...] -i|-o DIR|--help\n
      \t\t#{$PROGRAM_NAME}\t - name of script
      \t\tfile.gpx file2.gpx\t - one or more file names to fix
      \t\t-i\t - fix files 'in place'
      \t\t-o DIR\t - put output files to directory DIR
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

    def create_dir(dir)
      begin
        Dir.mkdir(dir)
      rescue
        # do nothing
      end
    end
end
