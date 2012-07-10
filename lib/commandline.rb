
class Commandline
	HELP_STRING="help"

  def initialize(given_arguments)
    puts "given_arguments: #{given_arguments}"
    @arguments = given_arguments

    @edit_in_place=false
    @expecting_dir=false
    @output_dir=nil

    @files = []

    @print_help = false
  end

	def to_s
		strs="Arguments: "+@arguments.join(" ")+"; "
    strs+="files.count: #{@files.count}; "
    strs+="output_dir: #{@output_dir}; "
    strs+="edit_in_place: #{@edit_in_place}; "
	end

	def parse
    @arguments.each { |a|
		  if a.start_with?("-")
		  	parse_switch a
		  else
		  	parse_arg a
		  end
		}

    if @files.count == 0
      puts "ERROR: No input files specified."
      print_help
    end

    if (@expecting_dir == true && @output_dir.nil?)
      puts "ERROR: Expecting argument for '-a' switch"
      print_help
    end

    if @edit_in_place && @output_dir
        puts "Could not use both '-i' and '-a' switch.\n"
        print_help
    end
	end

	def parse_switch(arg)
		argument = arg[1..-1].downcase

    if argument.eql?("i")
      if ( @edit_in_place || @expecting_dir )
        puts "Invalid usage of '-i' switch."
        print_help
      else
        puts "arg eql i"
        @edit_in_place=true
      end
    end

    if argument.eql?("a")
      puts "arg eql a"

      if @expecting_dir==false
        @expecting_dir=true
      else
        puts "Argument DIR expected after '-a' switch\n"
        print_help
      end
    end

    if argument.end_with?(HELP_STRING)
      print_help
    end

		puts "Switch: #{argument}"
	end

	def parse_arg(arg)
    if @expecting_dir
      @output_dir=arg
      @expecting_dir=false

      puts "Dir: #{@output_dir}"
    else
      @files << arg unless arg.empty?
    end
	end

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
end
