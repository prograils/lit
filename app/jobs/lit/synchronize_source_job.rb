module Lit
  if defined?(::ActiveJob)
    class SynchronizeSourceJob < ::ActiveJob::Base
      queue_as :default

      def perform(source)
        source.synchronize
      end
    end
  end
end
