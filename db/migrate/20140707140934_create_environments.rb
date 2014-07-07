class CreateEnvironments < ActiveRecord::Migration
  def change
    create_table :environments do |t|
      t.references :project, index: true
      t.string :name
      t.string :branch
      t.string :application_url

      t.timestamps
    end
  end
end
