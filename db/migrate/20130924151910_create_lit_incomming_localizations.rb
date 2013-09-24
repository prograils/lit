class CreateLitIncommingLocalizations < ActiveRecord::Migration
  def change
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
    add_index :lit_incomming_localizations, :locale_id
    add_index :lit_incomming_localizations, :localization_key_id
    add_index :lit_incomming_localizations, :localization_id
    add_index :lit_incomming_localizations, :source_id
    add_index :lit_incomming_localizations, :incomming_id
  end
end
