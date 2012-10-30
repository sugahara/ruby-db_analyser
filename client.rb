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
      ActiveRecord::Base.establish_connection(config)
      @tablelist = ActiveRecord::Base.connection.tables
      TargetTable.set_table_name(@tablelist.first.to_sym)
    end
    
  end
end
