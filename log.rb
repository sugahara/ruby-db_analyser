require 'logger'
module DBAnalyser
  
  class Log < Logger
    def initialize(logdev)
      super(logdev)
      # @logger = File.open(logfile, 'w')
      self.formatter = proc{|severity, datetime, progname, message|
        "#{message}\n"
      }
    end
    
    def log_array(array)
      array.each do |v|
        info(v)
      end
    end

  end
end
