class LitCreateLitLocales < Rails::VERSION::MAJOR >= 5   ?
                            ActiveRecord::Migration[4.2] :
                            ActiveRecord::Migration
  def up
    return if table_exists?(:lit_locales)
    create_table :lit_locales do |t|
      t.string :locale

      t.timestamps
    end
  end

  def down
    drop_table :lit_locales
  end
end
