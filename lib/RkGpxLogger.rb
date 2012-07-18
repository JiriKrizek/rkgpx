require 'logger'

class RkGpxLogger < Logger
  FORMAT="%H:%M:%S"

  def initialize(output, lev=Logger::DEBUG)
  	super(output, 'daily')
    self.level = lev
    self.datetime_format = FORMAT
    self.debug("Starting #{$PROGRAM_NAME}")
  end
  
end
