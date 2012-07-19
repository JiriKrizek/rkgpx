#require 'nokogiri'

class GpxMerged
    attr_accessor :log

    def initialize(files, logger)
      @log = logger

      @files=files
      @files = ["1.gpx", "error", "2.gpx"]
      @files.each { |file|
        if File.readable?(file)
          gpx = Gpx.new(file, @log)
          gpx.fix_trkseg
          gpx.save_in_place
        else
          log.info "File #{file} is not readable or does not exist. Skipping."
        end
      }
    end
end
