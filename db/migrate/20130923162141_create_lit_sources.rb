class CreateLitSources < ActiveRecord::Migration
  def change
    create_table :lit_sources do |t|
      t.string :identifier
      t.string :url
      t.string :api_key
      t.datetime :last_updated_at

      t.timestamps
    end
  end
end
