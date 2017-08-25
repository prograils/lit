class CreateLitLocalizationKeys < Rails::VERSION::MAJOR >= 5 ? ActiveRecord::Migration[4.2] : ActiveRecord::Migration
  def change
    create_table :lit_localization_keys do |t|
      t.string :localization_key

      t.timestamps
    end
    add_index :lit_localization_keys, :localization_key, :unique=>true
  end
end
