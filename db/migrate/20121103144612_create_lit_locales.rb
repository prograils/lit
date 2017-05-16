class CreateLitLocales < Rails::VERSION::MAJOR >= 5 ? ActiveRecord::Migration[4.2] : ActiveRecord::Migration
  def change
    create_table :lit_locales do |t|
      t.string :locale

      t.timestamps
    end
  end
end
