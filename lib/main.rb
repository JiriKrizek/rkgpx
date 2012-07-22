require_relative "RkGpxLogger"
require_relative "commandline"
require_relative "gpx"
require_relative "GpxMerged"

# Enable logging
log = RkGpxLogger.new(STDOUT)

# Parse commandline arguments and prepare output directory
cmd = Commandline.new(ARGV)
cmd.parse
log.debug cmd.to_s


gpx_merged = GpxMerged.new(cmd.files, log)