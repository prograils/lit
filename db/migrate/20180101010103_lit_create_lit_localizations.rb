class LitCreateLitLocalizations < ActiveRecord::Migration[5.1]
  def up
    return if table_exists?(:lit_localizations)
    create_table :lit_localizations do |t|
      t.references :locale
      t.references :localization_key
      t.text :default_value
      t.text :translated_value
      t.boolean :is_changed, default: false

      t.timestamps
    end
  end

  def down
    remove_index :lit_localizations, :locale_id
    remove_index :lit_localizations, :localization_key_id
  end
end
