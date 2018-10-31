class LitAddLocalizationKeyIsDeletedToLocalizationKeys < Rails::VERSION::MAJOR >= 5   ?
                                                      ActiveRecord::Migration[4.2] :
                                                      ActiveRecord::Migration
  def change
    add_column :lit_incomming_localizations, :localization_key_is_deleted,
               :boolean, null: false, default: false
  end
end
