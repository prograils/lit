module Lit
  extend self
  def activesupport
    $activesupport ||= ActiveSupport::Cache::MemoryStore.new size: 1250.kilobytes
  end
  class MemoryStorage
    def initialize
      Lit.activesupport
    end

    def [](key)
      Lit.activesupport.read(key)
    end

    def []=(k, v)
      delete(k)
      Lit.activesupport.write(k,v)
    end

    def delete(k)
      Lit.activesupport.delete(k)
    end

    def clear
      Lit.activesupport.clear
    end
    
    def keys
      Lit.activesupport.instance_eval do
        @data.keys
      end
    end

    def has_key?(key)
      Lit.activesupport.exist?(key)
    end

    def incr(key)
      Lit.activesupport.increment(key)
    end

    def sort
      Lit.activesupport.keys.sort.map do |k|
        [k, self.[](k)]
      end
    end
  end
end
