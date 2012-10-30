require File.expand_path(File.dirname(__FILE__) + '/packet-client.rb')
require File.expand_path(File.dirname(__FILE__) + '/log.rb')


db_host = ARGV[0]
db_user_name = ARGV[1]
db_pass = ARGV[2]
db_name = ARGV[3]
delta_t = ARGV[4].to_f

# Basic config of ActiveRecord
config = {
  :adapter => 'mysql',
  :host => db_host,
  :username => db_user_name,
  :password => db_pass,
  :database => db_name
}

# Set conditions to analyse
conditions = {
   #:protocol_3 = >"udp"
}

packet_client = DBAnalyser::PacketClient.new(config)
logger = DBAnalyser::Log.new("iat.txt")
#packet_client.packet_length(conditions)
packet_client.packet_iat(conditions)

#logger.log_array(length)
#logger.close
