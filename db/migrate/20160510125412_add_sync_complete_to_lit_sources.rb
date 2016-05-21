class AddSyncCompleteToLitSources < ActiveRecord::Migration
  def change
    add_column :lit_sources, :sync_complete, :boolean
  end
end
