require 'lit/adapters/hybrid_storage'
def clear_snapshots
  Lit.reset_hash if defined?($_hash)
  Lit.hash_snapshot = nil if defined?($_hash_snapshot)
  Lit.redis.del(Lit.prefix + '_snapshot') if defined?($redis)
end
