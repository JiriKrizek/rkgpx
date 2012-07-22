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
      output = String.new

      in_trk_seg = false
      @contents.each_line { |l|
        tag=l.strip

        if tag =~ /^<trkseg>$/
          if in_trk_seg
            output+="</trkseg>\n"
          end
          in_trk_seg = true
        elsif tag =~ /^<\/trkseg>$/
          in_trk_seg = false
        end

        output+=l
      }
      @contents=output
      output
    end

    def save_in_place
      @log.fatal "Invalid operation! TO REMOVE"
      fd = IO.sysopen "kk", "w"
      iostream = IO.new(fd, "w")
      iostream.puts @contents
      iostream.close
    end
    
end
