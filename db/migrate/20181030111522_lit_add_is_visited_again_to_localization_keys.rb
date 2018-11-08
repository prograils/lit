class LitAddIsVisitedAgainToLocalizationKeys < Rails::VERSION::MAJOR >= 5   ?
                                               ActiveRecord::Migration[4.2] :
                                               ActiveRecord::Migration
  def change
    add_column :lit_localization_keys, :is_visited_again, :boolean,
               null: false, default: false
  end
end
