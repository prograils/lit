class LitAddIsDeletedToLocalizationKeys < ActiveRecord::Migration[7.0]
  def change
    add_column :lit_localization_keys, :is_deleted, :boolean,
      default: false, null: false
  end
end
