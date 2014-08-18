class RemoveFinishAtForDeployment < ActiveRecord::Migration
  def change
    remove_column :deployments, :finished_at
  end
end
