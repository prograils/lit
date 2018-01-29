class LitCreateLitSources < Rails::VERSION::MAJOR >= 5   ?
                            ActiveRecord::Migration[4.2] :
                            ActiveRecord::Migration
  def up
    return if table_exists?(:lit_sources)
    create_table :lit_sources do |t|
      t.string :identifier
      t.string :url
      t.string :api_key
      t.datetime :last_updated_at

      t.timestamps
    end
  end

  def down
    drop_table :lit_sources
  end
end
