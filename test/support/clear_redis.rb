require 'redis'
$redis.flushall if defined?($redis) && !$redis.nil?
