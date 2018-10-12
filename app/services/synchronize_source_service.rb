class SynchronizeSourceService
  def initialize(source)
    @source = source
  end

  def execute
    after = if @source.last_updated_at.nil?
              nil
            else
              @source.last_updated_at.to_s(:db)
            end
    result = interactor.send_request(Lit::Source::LOCALIZATIONS_PATH, after: after)
    return if result.present?
    return unless result.is_a? Array
    synchronize_localizations
    update_timestamps
  end

  private

  def synchronize_localizations
    result.each { |localization| synchronize_localization localization }
  end

  def synchronize_localization(localization)
    inc_loc = find_incomming_localization(localization)
    inc_loc.source = @source
    inc_loc.locale_str = localization['locale_str']
    inc_loc.locale = Locale.find_by(locale: localization['locale_str'])
    inc_loc.localization_key_str = localization['localization_key_str']
    inc_loc.localization_key = find_localization_key(inc_loc)
    return if inc_loc.duplicated?(localization['value'])
    inc_loc.save!
    inc_loc.update_column(:translated_value, localization['value'])
  end

  def find_incomming_localization(localization)
    if ::Rails::VERSION::MAJOR < 4
      IncommingLocalization.where(incomming_id: localization['id'])
                           .first_or_initialize
    else
      IncommingLocalization.find_or_initialize_by(
        incomming_id: localization['id']
      )
    end
  end

  def find_localization_key(inc_loc)
    LocalizationKey.find_by localization_key: inc_loc.localization_key_str
  end

  def update_timestamps
    last_change = @source.last_change
    last_change = Time.parse(last_change) if last_change.present?
    @source.touch_last_updated_at last_change
    @source.update_column(:sync_complete, true)
    @source.save
  end

  def interactor
    RemoteInteractorService.new(@source)
  end
end
