require_relative "RkGpxLogger"
require_relative "commandline"
require_relative "gpx"
require_relative "GpxMerged"

# Enable logging
LOGFILE="logs/logfile.txt"

log = RkGpxLogger.new(LOGFILE, Logger::DEBUG)

# Parse commandline arguments and prepare output directory
cmd = Commandline.new(ARGV, log)
cmd.parse
log.debug cmd.to_s


gpx_merged = GpxMerged.new(cmd.files, log, cmd.threshold, :in_place => cmd.edit_in_place, 
                           :merge => cmd.merge)
