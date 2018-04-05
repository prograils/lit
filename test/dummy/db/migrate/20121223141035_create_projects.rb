class CreateProjects < Rails::VERSION::MAJOR >= 5   ?
                       ActiveRecord::Migration[4.2] :
                       ActiveRecord::Migration

  def change
    create_table :projects do |t|
      t.string :name

      t.timestamps
    end
  end
end
