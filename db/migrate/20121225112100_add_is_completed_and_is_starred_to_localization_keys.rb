class AddIsCompletedAndIsStarredToLocalizationKeys < Rails::VERSION::MAJOR >= 5 ? ActiveRecord::Migration[4.2] : ActiveRecord::Migration
  def change
    add_column :lit_localization_keys, :is_completed, :boolean, :default=>false
    add_column :lit_localization_keys, :is_starred, :boolean, :default=>false
  end
end
