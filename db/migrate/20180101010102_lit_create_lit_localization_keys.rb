class LitCreateLitLocalizationKeys < ActiveRecord::Migration[7.0]
  def up
    return if table_exists?(:lit_localization_keys)

    create_table :lit_localization_keys do |t|
      t.string :localization_key

      t.timestamps
    end
    add_index :lit_localization_keys, :localization_key, unique: true
  end

  def down
    remove_index :lit_localization_keys, :localization_key
    drop_table :lit_localization_keys
  end
end
