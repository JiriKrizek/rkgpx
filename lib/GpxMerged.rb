require_relative '../lib/gpx'
require_relative '../lib/haversine.rb'

class GpxMerged
  include Gps

  attr_accessor :log
  attr_reader :in_place, :dir, :threshold

  def initialize(files, logger, threshold, options={})
    @log = logger

    if options.has_key?(:in_place) && options[:in_place]
      @log.debug "Edit in place"
      @in_place = options[:in_place]
    elsif options.has_key?(:output_dir) && options[:output_dir]
      @log.debug "Save output to dir #{@dir}"
      @dir = options[:output_dir]
    else
      @log.debug "Raised ArgumentError exception"
      raise ArgumentError.new("Either option :output_dir or option :in_place must be provided")
    end

    @hash=Hash.new

    @threshold = threshold
    @files=files
    @files.each { |file|
      if File.readable?(file)
        gpx = Gpx.new(file, @log)
        @log.debug "=== Processing file #{gpx.filename}"

        begin
          gpx.fix_trkseg
        rescue XmlParseError => e
          @log.warn "trkseg for file '#{gpx.filename}' not fixed with error #{e.message}"
          next
        end

        @log.debug "Parsed file attributes: "
        @log.debug "\t\tType:   '#{gpx.gpx_type}'"
        @log.debug "\t\tTime:   '#{gpx.gpx_time}'"
        @log.debug "\t\tOffset: '#{gpx.gpx_time_offset_hours}' hours"

        @log.debug "Starting fix_timestamps:"
        gpx.fix_timestamps

        #dont save for now TODO
        #gpx.save_in_place
      else
        log.info "File #{file} is not readable or does not exist. Skipping."
      end
      unless @hash.has_key?(gpx.gpx_time.to_s)
        @hash[gpx.gpx_time.to_s] = gpx
      else
        @log.warn "GPX file with start time #{gpx.gpx_time.to_s} already defined, ignoring."
      end
      @log.debug "=== File #{gpx.filename} processed"
    }
    @log.debug "Finished processing of individual gpx files."

    @gpx_output = Array.new
    @hash.each { |key, value|
      @gpx_output << value
    }

    @gpx_output.each {|g|
      g.filename
    }

    @gpx_output.sort_by!(&:gpx_time)

    @log.debug "GPX files sorted."

    activities = Array.new
    activities << @gpx_output[0] unless @gpx_output.empty?

    @gpx_output.each_with_index { |gpx, index|
      @log.debug "#{gpx.filename}: #{gpx.gpx_time}\t[#{gpx.gpx_type}]  [#{index}]"

      if ((index-1) >= 0)
        gpx_prev = @gpx_output[index-1]

        first =       gpx.trkpt_first
        last  =  gpx_prev.trkpt_last

        @log.debug "Distance between #{gpx.filename}.first and #{@gpx_output[index-1].filename}.last is #{distance(first, last)["m"]} meters"
        dst = distance(first, last)["m"].round(2)
        if dst > @threshold
          @log.warn "Distance #{dst} meters is bigger than defined threshold (#{@threshold} meters). Consider change threshold using switch '-t number'"
        else
          activities << gpx
          @log.debug "Distance #{dst} m <= threshold #{@threshold} m, adding activity #{gpx.filename}"
          activities.each { |a|
            @log.debug "\t\t#{a.filename}"
          }
        end
      end
    }
  end
end
