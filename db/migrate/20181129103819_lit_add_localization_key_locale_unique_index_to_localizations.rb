class LitAddLocalizationKeyLocaleUniqueIndexToLocalizations < Rails::VERSION::MAJOR >= 5   ?
                                                              ActiveRecord::Migration[4.2] :
                                                              ActiveRecord::Migration
  def change
    add_index :lit_localizations, [:localization_key_id, :locale_id], unique: true
  end
end
