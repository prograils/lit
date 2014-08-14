require 'redis'
$redis.flushall if defined?($redis) and not $redis.nil?
