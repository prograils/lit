class PersitGlobalHitsCountersService
  def initialize(update_array)
    @update_array = update_array
  end

  def execute
    @update_array.each do |a|
      Lit::LocalizationKey.find(a[0]).update_columns(usage_count: a[1], used_last_at: Time.now)
    end
  end

end
