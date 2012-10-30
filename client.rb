require 'active_record'


module DBAnalyser
  class TargetTable < ActiveRecord::Base
  end

  module Config
    Generic = {
      :adapter => 'mysql',
      :host => nil,
      :username => nil,
      :password => nil,
      :database => nil
    }
  end

  class GenericClient
    def initialize(config = config.dup.update(DNAnalyserConfig::Generic))
      #ActiveRecord::Base.logger = Logger.new(STDOUT)
      ActiveRecord::Base.establish_connection(config)
      @tablelist = ActiveRecord::Base.connection.tables
      TargetTable.table_name = @tablelist.first
    end
    
  end
end
