class LitAddLocalizationKeyIsDeletedToLocalizationKeys < ActiveRecord::Migration[7.0]
  def change
    add_column :lit_incomming_localizations, :localization_key_is_deleted,
      :boolean, null: false, default: false
  end
end
