require 'lit/adapters/hybrid_storage'
def clear_snapshots
  trace_var :$_hash, proc { |h| print 'hash is now', v }
  Lit.reset_hash if defined?($_hash)
  Lit.hash_snapshot = nil if defined?($_hash_snapshot)
  Lit.redis.del('lit:_snapshot') if defined?($redis)
end
