require_relative '../lib/gpx'

class GpxMerged
    attr_accessor :log
    attr_reader :in_place, :dir

    def initialize(files, logger, options={})
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

      @gpx_output=[]

      @files=files
      @files.each { |file|
        if File.readable?(file)
          gpx = Gpx.new(file, @log)
          @log.debug "=== Processing file #{gpx.filename}"

          begin
            gpx.fix_trkseg
          rescue XmlParseError => e
            @log.warn "trkseg for file '#{gpx.filename}' not fixed with error #{e.message}"
            return
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
        @gpx_output << gpx
        @log.debug "=== File #{gpx.filename} processed"
      }

      @gpx_output.sort_by!(&:gpx_time)

      @gpx_output.each { |gpx|
        @log.debug "#{gpx.filename}: #{gpx.gpx_time}"
        gpx.gpx_time_offset_hours

      }
    end
end
