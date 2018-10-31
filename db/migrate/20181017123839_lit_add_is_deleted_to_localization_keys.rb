class LitAddIsDeletedToLocalizationKeys < Rails::VERSION::MAJOR >= 5   ?
                                       ActiveRecord::Migration[4.2] :
                                       ActiveRecord::Migration
  def change
    add_column :lit_localization_keys, :is_deleted, :boolean,
               default: false, null: false
  end
end
