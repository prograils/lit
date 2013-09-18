module Lit
  class HashStorage < Hash
    def incr(key)
      self[key] ||= 0
      self[key] += 1
    end
  end
end