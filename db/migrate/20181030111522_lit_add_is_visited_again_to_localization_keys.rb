class LitAddIsVisitedAgainToLocalizationKeys < ActiveRecord::Migration[7.0]
  def change
    add_column :lit_localization_keys, :is_visited_again, :boolean,
      null: false, default: false
  end
end
