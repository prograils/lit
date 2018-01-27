class LitCreateLitLocalizationVersions < ActiveRecord::Migration[5.1]
  def up
    return if table_exists?(:lit_localization_versions)
    create_table :lit_localization_versions do |t|
      t.text :translated_value
      t.references :localization

      t.timestamps
    end
  end

  def down
    remove_index :lit_localization_versions, :localization_id
    drop_table :lit_localization_versions
  end
end
