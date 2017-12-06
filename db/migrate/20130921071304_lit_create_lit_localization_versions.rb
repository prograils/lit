class LitCreateLitLocalizationVersions < ActiveRecord::Migration
  def up
    return if table_exists?(:lit_localization_versions)
    create_table :lit_localization_versions do |t|
      t.text :translated_value
      t.references :localization

      t.timestamps
    end
    add_index :lit_localization_versions, :localization_id
  end

  def down
    remove_index :lit_localization_versions, :localization_id
    drop_table :lit_localization_versions
  end
end
