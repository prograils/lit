class LitCreateLitIncommingLocalizations < ActiveRecord::Migration[7.0]
  def up
    return if table_exists?(:lit_incomming_localizations)

    create_table :lit_incomming_localizations do |t|
      t.text :translated_value
      t.integer :locale_id
      t.integer :localization_key_id
      t.integer :localization_id
      t.string :locale_str
      t.string :localization_key_str
      t.integer :source_id
      t.integer :incomming_id

      t.timestamps
    end

    add_index :lit_incomming_localizations, :locale_id
    add_index :lit_incomming_localizations, :localization_key_id
    add_index :lit_incomming_localizations, :localization_id
    add_index :lit_incomming_localizations, :source_id
    add_index :lit_incomming_localizations, :incomming_id
  end

  def down
    remove_index :lit_incomming_localizations, :locale_id
    remove_index :lit_incomming_localizations, :localization_key_id
    remove_index :lit_incomming_localizations, :localization_id
    remove_index :lit_incomming_localizations, :source_id
    remove_index :lit_incomming_localizations, :incomming_id
    drop_table :lit_incomming_localizations
  end
end
