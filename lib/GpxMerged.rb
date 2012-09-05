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

      @files=files
      @files.each { |file|
        if File.readable?(file)
          gpx = Gpx.new(file, @log)
          gpx.fix_trkseg

          @log.info "XML: \n#{gpx.contents}"

          #dont save for now TODO
          #gpx.save_in_place
        else
          log.info "File #{file} is not readable or does not exist. Skipping."
        end
      }
    end
end
