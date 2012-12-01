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

    def initialize(config = {}, default = DBAnalyser::Config::Generic)
      @config = default.dup.update(config)
      # ActiveRecord::Base.logger = Logger.new(STDOUT)
      ActiveRecord::Base.establish_connection(@config)
      if @config[:tables].first.nil?
        @tablelist = ActiveRecord::Base.connection.tables
      else
        @tablelist = @config[:tables]
      end
      TargetTable.table_name = @tablelist.first
    end
    
  end
end
