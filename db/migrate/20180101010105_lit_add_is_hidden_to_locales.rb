class LitAddIsHiddenToLocales < Rails::VERSION::MAJOR >= 5   ?
                                ActiveRecord::Migration[4.2] :
                                ActiveRecord::Migration
  def up
    return if column_exists?(:lit_locales, :is_hidden)
    add_column :lit_locales, :is_hidden, :boolean, default: false
  end

  def down
    remove_column :lit_locales, :is_hidden
  end
end
