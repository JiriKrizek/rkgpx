require 'nokogiri'
require_relative 'XmlParseError'

class Gpx
  attr_reader :contents, :filename, :xml_doc

  def initialize(filename, logger)
    @log = logger
    @filename = filename

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
    @contents = @contents.gsub(/<\/trk>/, "\n"+'\0'+"\n")

    @contents.each_line { |l|
      tag=l.strip

      if tag =~ /^<trkseg>$/
        # Close trkseg tag before another <trkseg>
        if in_trk_seg
          output+="</trkseg>\n"
        end
        in_trk_seg = true
      elsif tag =~ /<\/trkseg>/
        in_trk_seg = false
      end

      # Close trkseg tag before </trk>
      if in_trk_seg && tag =~ /<\/trk>/ 
        output+="</trkseg>\n"
      end

      output+=l
    }

    # Close gpx tag at the end of the document
    output += "</gpx>" unless output.split("\n").last =~ /.*<\/gpx>\s*/

    # Tidy XML output
    doc = Nokogiri::XML(output)

    @contents = doc.to_xml

    unless doc.errors.empty?
      msg = String.new "Encountered problems during XML parsing. Output XML file might not be valid.\n #{doc.errors.last}"
      raise XmlParseError.new(msg)
    end

    @log.info "Fixed trkseg for file '#{filename}'"
    @xml_doc = doc
  end

  def save_in_place
    @log.fatal "Invalid operation! TO REMOVE"
    fd = IO.sysopen "kk", "w"
    iostream = IO.new(fd, "w")
    iostream.puts @contents
    iostream.close
  end

  def get_gpx_type
    return @gpx_type unless @type==nil
    trk_name

    @gpx_type
  end

  def get_gpx_date
    return @gpx_date unless @type==nil
    trk_name

    @gpx_date
  end
private
  def trk_name
    txt = @xml_doc.xpath("/g:gpx/g:trk/g:name/text()", "g" => "http://www.topografix.com/GPX/1/1").to_s

    txt.scan(/\<\!\[CDATA\[([a-zA-Z]*)\w*(.*)\]\]>/) do |type, time|
      @gpx_type = type
      @log.debug "GPX type: #{@gpx_type}"
      @gpx_date = time
      @log.debug "GPX date: #{@gpx_date}"
    end
  end


end
