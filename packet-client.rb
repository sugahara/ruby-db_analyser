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

    def log_initialize(conditions, logger)
      logger.log("# conditions")
      conditons.each do |v, key|
        logger.log("#     #{key} => #{v}")
      end
    end

    def get_first_number(conditions)
      TargetTable.where(conditions).find(:first, :select => "number").number
    end
    
    def get_last_number(conditions)
      TargetTable.where(conditions).find(:last, :select => "number").number
    end
    
    def packet_length(conditions = {}, logger = DBAnalyser::Log.new(STDOUT))
      #これprotocol4指定した場合，tcp.reassembled.lengthでlength取らなちょっと矛盾あるしそのフィールド追加せなあかんやん　はよせな
      temp_length_array = Array.new
      result_length_array = Array.new
      @tablelist.each do |table|
        puts "#{table}"
        TargetTable.table_name = table
        firstnum = get_first_number(conditions)
        lastnum = get_last_number(conditions)
        (firstnum..lastnum).each do |num|
          conditions.update(:number => num)
          if(conditions.has_key?(:protocol_4) || conditions.has_key?(:protocol_5))
            length_result = TargetTable.where(conditions).find(:all, :select => "tcp_reassembled_length").tcp_reassembled_length
          else
            length_result = TargetTable.where(conditions).find(:all, :select => "length").length
          end
          logger.info(length_result)
        end
        #length_result.each do |data|
        #  logger.info(temp_length_array << data.length)
        #end
        #result_length_array = result_length_array + temp_length_array
      end
      #result_length_array
    end
    
    def packet_iat(conditions = {}, logger = DBAnalyser::Log.new(STDOUT))
      iat_array = Array.new

      @tablelist.each do |table|
        puts "#{table}"
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
