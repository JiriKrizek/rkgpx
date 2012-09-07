require 'nokogiri'
require 'time'
require 'date'
require_relative 'XmlParseError'

class Gpx
  attr_reader :contents, :filename, :xml_doc
  GPX_MAPPING={"g" => "http://www.topografix.com/GPX/1/1"}

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
    @gpx_type=trk_comment_name

    @gpx_type
  end

  def get_gpx_time
    return @gpx_date unless @type==nil
    @gpx_date=trk_comment_time

    @gpx_date
  end

  def get_gpx_timestamp
    return @gpx_timestamp unless @gpx_timestamp==nil
    @gpx_timestamp=trk_xml_time

    @gpx_timestamp
  end

  def get_gpx_time_offset_hours
    date_gpx = get_gpx_time
    xml_time = get_gpx_timestamp
    @log.debug "Date_gpx #{date_gpx}"
    @log.debug "Xml_time #{xml_time}"

    diff_hours = ((xml_time - date_gpx)/3600).round
    @log.debug "Diff between \n\t\t\t\t#{xml_time} and \n\t\t\t\t#{date_gpx} is #{diff_hours} hours"
  end
private
  def trk_comment_name
    txt = @xml_doc.xpath("/g:gpx/g:trk/g:name/text()", GPX_MAPPING).to_s

    type=txt.slice(/\<\!\[CDATA\[([a-zA-Z]*)\w*.*\]\]>/, 1)
    #@log.debug "GPX type: '#{type}'"
    type
  end

  def trk_comment_time
    txt = @xml_doc.xpath("/g:gpx/g:trk/g:name/text()", GPX_MAPPING).to_s

    time = txt.slice(/\<\!\[CDATA\[[a-zA-Z]*\w*(.*)\]\]>/, 1)
    date_gpx=convert_timestr_to_time(time)

    date_gpx
  end

  def trk_xml_time
    trktime = @xml_doc.xpath("/g:gpx/g:trk/g:time/text()", GPX_MAPPING).to_s

    xml_time = Time.parse(trktime)
    @log.debug "XML time #{xml_time}"
    xml_time
  end

  def convert_timestr_to_time(time)
    time.strip!
    time += " UTC"

    Time.parse(DateTime.strptime(time, '%m/%d/%y %I:%M %P %Z').to_s).utc
  end


end
