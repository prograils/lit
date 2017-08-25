class CreateLitLocalizationVersions < Rails::VERSION::MAJOR >= 5 ? ActiveRecord::Migration[4.2] : ActiveRecord::Migration
  def change
    create_table :lit_localization_versions do |t|
      t.text :translated_value
      t.references :localization

      t.timestamps
    end
    add_index :lit_localization_versions, :localization_id
  end
end
