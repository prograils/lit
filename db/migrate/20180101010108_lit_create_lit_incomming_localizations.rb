class LitCreateLitIncommingLocalizations < Rails::VERSION::MAJOR >= 5  ?
                                          ActiveRecord::Migration[4.2] :
                                          ActiveRecord::Migration
  def up
    return if table_exists?(:lit_incomming_localizations)
    create_table :lit_incomming_localizations do |t|
      t.text :translated_value
      t.references :locale
      t.references :localization_key
      t.references :localization
      t.string :locale_str
      t.string :localization_key_str
      t.references :source
      t.integer :incomming_id

      t.timestamps
    end

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
