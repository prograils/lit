module Lit
  module SourcesHelper
    def source_loading_class(source)
      source.sync_complete ? 'loaded' : 'loading'
    end
  end
end
