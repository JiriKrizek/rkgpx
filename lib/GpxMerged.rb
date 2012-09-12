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

    @threshold = threshold
    @files=files

    hash = Hash.new
    # Generate Gpx object for each file
    @files.each { |file|
      if File.readable?(file)
        gpx = Gpx.new(file, @log)
        @log.debug "=== Processing file #{gpx.filename}"

        begin
          gpx.fix_trkseg
        rescue XmlParseError => e
          # Skip file in case of error
          @log.warn "trkseg for file '#{gpx.filename}' not fixed with error #{e.message}"
          next
        end

        @log.debug "Parsed file attributes: "
        @log.debug "\t\tType:   '#{gpx.gpx_type}'"
        @log.debug "\t\tTime:   '#{gpx.gpx_time}'"
        @log.debug "\t\tOffset: '#{gpx.gpx_time_offset_hours}' hours"

        @log.debug "Starting fix_timestamps:"
        gpx.fix_timestamps

        # Save file if in_place enabled
        if @in_place
          @log.debug "Inplace enabled. Saving file."

          save_in_place(gpx)
        end
      else
        log.info "File #{file} is not readable or does not exist. Skipping."
      end

      # Add file to hash only if there is no file with same gpx_time
      unless hash.has_key?(gpx.gpx_time.to_s)
        hash[gpx.gpx_time.to_s] = gpx
      else
        @log.warn "GPX file with start time #{gpx.gpx_time.to_s} already defined, ignoring."
      end

      @log.debug "=== File #{gpx.filename} processed"
    }
    @log.debug "Finished processing of individual gpx files."

    @gpx_output = sorted_uniq_gpx(hash)

    activities = []
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

          # Merge and continue
          xml_result_output = merge_gpx_files(activities)

          # Save output to file
          unless activities.empty?
            save_to_file(xml_result_output, activities)
            activities = []
          else
            @log.debug "Activities are empty (GpxMerged.rb)"
          end

        else
          activities << gpx
          @log.debug "Distance #{dst} m <= threshold #{@threshold} m, adding activity #{gpx.filename}"
        end
      end
    }

    unless activities.empty?
      @log.debug "Merging rest of activities"
      xml_result_output = merge_gpx_files(activities)

      save_to_file(xml_result_output, activities)
    end
  end

  # Merge sorted array of Gpx objects and return indented xml output
  def merge_gpx_files(sorted_array)
    raise ArgumentError.new("Invalid argument #{sorted_array.class}") unless sorted_array.kind_of? Array

    first = sorted_array.shift

    sorted_array.each { |a|
      # Appends <trkseg> from next gpx after last <trkseg> in first file
      first_trk=first.gpx_ns_all_trkseg
      trkseg=a.gpx_all_trkseg

      first_trk.after(trkseg)
    }

    # Converts to XML and returns
    first.xml_doc.to_xml(:indent => 2)
  end

  private
  def sorted_uniq_gpx(hash)
    gpx_output = []

    hash.each { |key, value|
      gpx_output << value
    }

    @log.debug "GPX files are now sorted and uniq."

    gpx_output.sort_by(&:gpx_time)
  end

  def save_to_file(output_str, act_array)
    filename="output_"
    filename+= act_array.last.gpx_timestamp.to_s.gsub(":", "-").gsub(" ", ".")
    filename+=".gpx"

    @log.debug "Adding these gpx to #{filename}:"
    act_array.each { |a|
      @log.debug "\t\t#{a.filename}"
    }

    File.open(filename, 'w') { |f| f.write(output_str) }
  end

  def save_in_place(gpx)
    raise ArgumentError.new("save_in_place(gpx): gpx must be kind_of Gpx object") unless gpx.kind_of? Gpx
    filename=gpx.filename
    @log.debug "Saving file '#{filename}'' in place"

    File.open(filename, 'w') { |f| f.write(gpx.xml_doc.to_xml(:indent => 2))}
  end
end
