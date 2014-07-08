class CreateDeployments < ActiveRecord::Migration
  def change
    create_table :deployments do |t|
      t.references :project, index: true
      t.references :location, index: true
      t.integer :state
      t.date :finish_at

      t.timestamps
    end
  end
end
