#require 'nokogiri'

class Gpx
    
    def initialize(filename, logger)
      @log = logger
      if File.readable?(filename)
        file = File.open(filename, "r")
        @filename = filename # TOREMOVE
        
        @contents = file.read
        @log.debug("File #{filename} is readable, loading into string")
      else
        error = "File '#{filename}' is NOT READABLE."

        @log.warn(error)
        raise ArgumentError.new(error)
      end
    end
    
    def fix_trkseg
      in_trkseg = false
      in_tag = false

      val = String.new
      @contents.each_char { |ch|
        val += ch
        if ch == ">"
          p val
          val = '' 
        end
      }
    end

    def save_in_place
      @log.fatal "Invalid operation! TO REMOVE"
      fd = IO.sysopen "kk", "w"
      iostream = IO.new(fd, "w")
      iostream.puts @contents
      iostream.close
    end
    
end
