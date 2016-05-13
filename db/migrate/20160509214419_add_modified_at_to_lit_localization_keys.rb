class AddModifiedAtToLitLocalizationKeys < ActiveRecord::Migration
  def change
    add_column :lit_localization_keys, :modified_at, :datetime
  end
end
