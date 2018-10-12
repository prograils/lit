module Lit
  if defined?(::ActiveJob)
    class SynchronizeSourceJob < ::ActiveJob::Base
      queue_as :default

      def perform(source)
        SynchronizeSourceService.new(source).execute
      end
    end
  end
end
