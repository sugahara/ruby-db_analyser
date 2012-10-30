module DBAnalyser
  require File.expand_path(File.dirname(__FILE__) + '/client.rb')
  
  class TimeslotClient < DBAnalyser::GenericClient
    DEFAULT_CONFIG = {:windowsize => 1}
    def initialize(config = config.dup.update(DEFAULT_CONFIG))
      super(config)
      @windowsize = config[:windowsize]
    end

    def packet(timeslot_config)

    end

end
