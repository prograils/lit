class AddModifiedAtToLitLocalizations < ActiveRecord::Migration
  def change
    add_column :lit_localizations, :modified_at, :datetime
  end
end
