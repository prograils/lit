class LitCreateLitLocalizations < ActiveRecord::Migration[7.0]
  def up
    return if table_exists?(:lit_localizations)

    create_table :lit_localizations do |t|
      t.integer :locale_id
      t.integer :localization_key_id
      t.text :default_value
      t.text :translated_value
      t.boolean :is_changed, default: false

      t.timestamps
    end

    add_index :lit_localizations, :locale_id
    add_index :lit_localizations, :localization_key_id
  end

  def down
    remove_index :lit_localizations, :locale_id
    remove_index :lit_localizations, :localization_key_id
  end
end
