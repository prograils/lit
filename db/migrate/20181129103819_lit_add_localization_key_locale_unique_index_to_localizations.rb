class LitAddLocalizationKeyLocaleUniqueIndexToLocalizations < ActiveRecord::Migration[7.0]
  def change
    add_index :lit_localizations, %i[localization_key_id locale_id], unique: true
  end
end
