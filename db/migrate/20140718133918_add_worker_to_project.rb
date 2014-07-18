class AddWorkerToProject < ActiveRecord::Migration
  def change
    add_reference :projects, :worker, index: true
  end
end
