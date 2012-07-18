require 'logger'

class RkGpxLogger < Logger
  FORMAT="%H:%M:%S"

  def initialize(output)
    super(output)
    this.level = Logger::DEBUG
    this.datetime_format = FORMAT
    this.debug("Starting #{$PROGRAM_NAME}")
  end
  
  
end
