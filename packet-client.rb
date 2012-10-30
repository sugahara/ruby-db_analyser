# -*- coding: utf-8 -*-
module DBAnalyser
  require File.expand_path(File.dirname(__FILE__) + '/client.rb')
  require File.expand_path(File.dirname(__FILE__) + '/log.rb')
  
  class PacketClient < DBAnalyser::GenericClient
    def initialize(config)
      super(config)
    end

    def time_gen(datetime, microsec)
      ms = 0.000001 * microsec
      datetime + ms
    end
    
    def packet_length(conditions = {}, logger = DBAnalyser::Log.new(STDOUT))
      #これprotocol4指定した場合，tcp.reassembled.lengthでlength取らなちょっと矛盾あるしそのフィールド追加せなあかんやん　はよせな
      temp_length_array = Array.new
      result_length_array = Array.new
      @tablelist.each do |table|
        puts "#{table}"
        #TargetTable.set_table_name(table.to_sym)
        TargetTable.table_name = table
        if(conditions.has_key?(:protocol_4))
          length_result = TargetTable.where(conditions).find(:all, :select => "tcp_reassembled_length")
        else
          length_result = TargetTable.where(conditions).find(:all, :select => "length")
        end
        length_result.each do |data|
          logger.info(temp_length_array << data.length)
        end
        result_length_array = result_length_array + temp_length_array
      end
      result_length_array
    end
    
    def packet_iat(conditions = {}, logger = DBAnalyser::Log.new(STDOUT))
      iat_array = Array.new

      @tablelist.each do |table|
        puts "#{table}"
        #TargetTable.set_table_name(table.to_sym)
        TargetTable.table_name = table
        result = TargetTable.where(conditions).find(:all, :select => "time, micro_second")
        result.each_with_index do |v, i|
          break if result[i+1] == nil
          time0 = v.time
          micro_second0 = v.micro_second
          time1 = result[i+1].time
          micro_second1 = result[i+1].micro_second
          iat_array << iat = time_gen(time1, micro_second1) - time_gen(time0, micro_second0)
          logger.info(iat)
        end
        iat_array
        #first_number = TargetTable.find(:first, :select => "number").number
        #last_number   = TargetTable.find(:last, :select => "number").number
        #(first_number...last_number).each do |number|
        #  puts number
        #  conditions.update(:number => number)
        #  result = TargetTable.where(conditions).find(:all, :select => "time, micro_second")
        #  
        #  time0 = result[0].time
        #  micro_second0 = result[0].micro_second
        #  conditions.update(:number => number+1)
        #  result = TargetTable.where(conditions).find(:all, :select => "time, micro_second")
        #  time1 = result[0].time
        #  micro_second1 = result[0].micro_second
        #  iat_array << iat = time_gen(time1, micro_second1) - time_gen(time0, micro_second0)
        #  logger.info(iat)
        #  iat_array
        # end
        #iat_array << time1 - time 0
        # not implimented yet
        # protocol4指定する場合は，分割されたTCPパケットも含めてIATをとるのと最終パケットのIATを取るの両方実装する．
      end
      
  end
    
  end
end
