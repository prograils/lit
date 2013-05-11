class AddIsHiddenToLocales < ActiveRecord::Migration
  def change
    add_column :lit_locales, :is_hidden, :boolean, :default=>false
  end
end
