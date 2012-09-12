require 'logger'
require_relative 'MultiIO'

class RkGpxLogger < Logger
  FORMAT="%H:%M:%S"

  def initialize(output, lev=Logger::DEBUG)
    super(MultiIO.new(File.open(output,'w'), STDOUT), 'daily')
    self.level = lev
    self.datetime_format = FORMAT
    self.debug("Starting #{$PROGRAM_NAME}")
  end
  
end
