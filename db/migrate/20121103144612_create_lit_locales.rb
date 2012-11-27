class CreateLitLocales < ActiveRecord::Migration
  def change
    create_table :lit_locales do |t|
      t.string :locale

      t.timestamps
    end
  end
end
