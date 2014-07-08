class CreateDeployments < ActiveRecord::Migration
  def change
    create_table :deployments do |t|
      t.references :location, index: true
      t.references :commit, index: true
      t.integer :status
      t.date :finished_at

      t.timestamps
    end
  end
end
