require 'logger'
module DBAnalyser
  
  class Log < Logger
    def initialize(logdev)
      unless logdev == STDOUT
        if File.exist?(logdev)
          puts "Are you sure to delete old log file?[y,n]"
          ans = readline(prompt = "", add_hist = false)
          if ans=="y"
            File.delete(logdev)
          else
            #do nothing
          end
        end
      end
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
