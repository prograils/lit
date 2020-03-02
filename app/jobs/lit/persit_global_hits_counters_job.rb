module Lit
  if defined?(::ActiveJob)
    class PersitGlobalHitsCountersJob < ::ActiveJob::Base
      queue_as :default

      def perform(update_array)
        PersitGlobalHitsCountersService.new(update_array).execute
      end
    end
  end
end
