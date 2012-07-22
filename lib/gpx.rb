require 'nokogiri'

class Gpx
    attr_reader :contents

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

      # Remove end of lines
      @contents.gsub!(/\r/, "")
      @contents.gsub!(/\n/, "")

      # Surround trkseg tag with \n
      @contents = @contents.gsub(/<trkseg>/, "\n"+'\0'+"\n")

      @contents.each_line { |l|
        tag=l.strip

        if tag =~ /^<trkseg>$/
          # Close trkseg tag before another <trkseg>
          if in_trk_seg
            output+="</trkseg>\n"
          end
          in_trk_seg = true
        elsif tag =~ /^<\/trkseg>$/
          in_trk_seg = false
        end

        # Close trkseg tag before </trk>
        if tag =~ /^<\/trk>$/
          output+="</trkseg>\n"
        end

        output+=l
      }

      # Tidy XML output
      doc = Nokogiri::XML(output)
      @contents = doc.to_xml
    end

    def save_in_place
      @log.fatal "Invalid operation! TO REMOVE"
      fd = IO.sysopen "kk", "w"
      iostream = IO.new(fd, "w")
      iostream.puts @contents
      iostream.close
    end
    
end
