class CreateDeployments < ActiveRecord::Migration
  def change
    create_table :deployments do |t|
      t.references :project, index: true
      t.references :environment, index: true
      t.string :state
      t.date :finish_at

      t.timestamps
    end
  end
end
