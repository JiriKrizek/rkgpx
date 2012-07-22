#require 'nokogiri'

class GpxMerged
    attr_accessor :log

    def initialize(files, logger)
      @log = logger

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
