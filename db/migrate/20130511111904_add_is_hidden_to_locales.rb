class AddIsHiddenToLocales < Rails::VERSION::MAJOR >= 5 ? ActiveRecord::Migration[4.2] : ActiveRecord::Migration
  def change
    add_column :lit_locales, :is_hidden, :boolean, :default=>false
  end
end
