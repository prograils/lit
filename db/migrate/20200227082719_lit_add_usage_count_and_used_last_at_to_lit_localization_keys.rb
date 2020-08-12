class LitAddUsageCountAndUsedLastAtToLitLocalizationKeys < Rails::VERSION::MAJOR >= 5   ?
                                       ActiveRecord::Migration[4.2] :
                                       ActiveRecord::Migration
  def change
    add_column :lit_localization_keys, :usage_count, :integer, index: true
    add_column :lit_localization_keys, :used_last_at, :datetime, index: true
  end
end
