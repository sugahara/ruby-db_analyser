# -*- coding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/packet-client.rb')
require File.expand_path(File.dirname(__FILE__) + '/timeslot-client.rb')
require File.expand_path(File.dirname(__FILE__) + '/log.rb')
require 'benchmark'
require 'time'

puts Benchmark.measure{
  db_host = ARGV[0]
  db_user_name = ARGV[1]
  db_pass = ARGV[2]
  db_name = ARGV[3]
  delta_t = ARGV[4].to_f
  start_time = Time.parse(ARGV[5])
  end_time = Time.parse(ARGV[6])
  tables = ARGV[7...ARGV.size]

  # Basic config of ActiveRecord
  config = {
    :adapter => 'mysql',
    :host => db_host,
    :username => db_user_name,
    :password => db_pass,
    :database => db_name,
    :delta_t => delta_t,
    :tables => tables,
    :time => start_time..end_time
  }

  # Set conditions to analyse
  conditions = {
    #:protocol_3 =>"udp"
  }

  timeslot_client = DBAnalyser::TimeslotClient.new(config)
  #logger = DBAnalyser::Log.new("")
  timeslot_client.packet(conditions)

}
puts Benchmark::CAPTION
