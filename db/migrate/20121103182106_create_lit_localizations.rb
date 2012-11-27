class CreateLitLocalizations < ActiveRecord::Migration
  def change
    create_table :lit_localizations do |t|
      t.references :locale
      t.references :localization_key
      t.text :default_value
      t.text :translated_value
      t.boolean :is_changed, :default=>false

      t.timestamps
    end
    add_index :lit_localizations, :locale_id
    add_index :lit_localizations, :localization_key_id
  end
end
