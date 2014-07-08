class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.references :project
      t.string :name
      t.string :branch
      t.string :application_url

      t.timestamps
    end
  end
end
