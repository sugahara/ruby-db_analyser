# -*- coding: utf-8 -*-
module DBAnalyser
  require File.expand_path(File.dirname(__FILE__) + '/client.rb')
  require File.expand_path(File.dirname(__FILE__) + '/log.rb')
  require 'ruby-debug'
  
  class TimeslotClient < DBAnalyser::GenericClient
    DEFAULT_CONFIG = {:delta_t => 1.0}
    def initialize(config = {}, default = DEFAULT_CONFIG)
      config = default.dup.update(config)
      super(config)
      @delta_t = config[:delta_t]
      @second_changed = false
    end
    
    def get_first_time(filtered_table)
      # filtered_table.find(:first, :select => "time").time + (filtered_table.find(:first, :select => "micro_second").micro_second / 1000000)
      filtered_table.find(:first, :select => "time").time
    end

    def get_last_time(filtered_table)
      filtered_table.find(:last, :select => "time").time + (filtered_table.find(:last, :select => "micro_second").micro_second / 1000000)
    end

    def check_timeslot_second(timeslot, delta_t)
      if timeslot.first.sec != timeslot.last.sec && delta_t < 1.0
        @second_changed = true
      else
        @second_changed = false
      end
    end
    
    def get_timeslot(start_time, delta_t)
      timeslot = start_time...(start_time + delta_t)
      #1秒未満のウィンドウサイズで秒数が変わった時の対処
      check_timeslot_second(timeslot, delta_t)
      puts "timeslot:#{timeslot}"
      timeslot
    end

    def slide_timeslot(prev_timeslot, delta_t)
      timeslot = prev_timeslot.last...prev_timeslot.last+delta_t
      check_timeslot_second(timeslot, delta_t)
      puts "timeslot:#{timeslot}"
      timeslot
    end

    def count(filtered_table, timeslot, delta_t)
      if @second_changed == true
        timeslot0 = timeslot
        timeslot1 = timeslot.first...(timeslot.last-timeslot.last.usec/1000000)
        timeslot2 = timeslot1.last...timeslot0.last
        return filtered_table.where(:time => timeslot1).where('micro_second > ?', timeslot1.first.usec).count + filtered_table.where(:time => timeslot2).where('micro_second < ?', timeslot2.first.usec).count
      else
        #p filtered_table.where(:time => timeslot).where('micro_second > ?', timeslot.first.usec).where('micro_second < ?', timeslot.last.usec).count
        filtered_table.where(:time => timeslot).count
      end
    end

    def packet(conditions = {}, logger = DBAnalyser::Log.new(STDOUT))
      timeslot = nil
      @tablelist.each_with_index do |table, i|
        tablenum = i
        puts "#{table}"
        TargetTable.table_name = table
        
        filtered_table = TargetTable.where(conditions)
        first_time = get_first_time(filtered_table)
        last_time = get_last_time(filtered_table)
        if timeslot.nil?
          # make first time slot
          timeslot = get_timeslot(first_time, @delta_t)
        end
        
        #そのテーブルパケットのカウント
        loop do
          if last_time <= timeslot.last && i < @tablelist.size - 1 ## テーブルをまたがるとき
            sum_of_count = 0
            table_count = 1
            loop do
              TargetTable.table_name = @tablelist[i+table_count]
              filtered_table = TargetTable.where(conditions)
              last_time = get_last_time(filtered_table)
              if last_time <= timeslot.last && i + table_count < @tablelist.size - 1
                table_count += 1
              else
                #debugger
                break;
              end
            end
            (table_count+1).times do |t|
              TargetTable.table_name = @tablelist[i+t]
              filtered_table = TargetTable.where(conditions)
              sum_of_count += count(filtered_table, timeslot, @delta_t)
            end
            logger.info(sum_of_count)
            timeslot = slide_timeslot(timeslot, @delta_t)
            break
          elsif last_time <= timeslot.last && i >= @tablelist.size - 1 ## 終了判定
            logger.info(count(filtered_table, timeslot, @delta_t))
            break
          else ## 1つのテーブルのみのとき
            logger.info(count(filtered_table, timeslot, @delta_t)) 
            timeslot = slide_timeslot(timeslot, @delta_t)
          end
        end

      end
    end

  end
end
