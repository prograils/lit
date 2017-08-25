class AddSyncCompleteToLitSources < Rails::VERSION::MAJOR >= 5 ? ActiveRecord::Migration[4.2] : ActiveRecord::Migration
  def change
    add_column :lit_sources, :sync_complete, :boolean
  end
end
