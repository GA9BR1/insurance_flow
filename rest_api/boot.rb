require 'sneakers'
require 'redis'
require 'json'

$redis = Redis.new

class Processor
  include Sneakers::Worker
  from_queue :logs

  def work(msg)
    err = JSON.parse(msg)
    if err["type"] == "error"
      $redis.incr "processor:#{err["error"]}"
    end

    ack!
  end
end
