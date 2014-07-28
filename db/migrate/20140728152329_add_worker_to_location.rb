class AddWorkerToLocation < ActiveRecord::Migration
  def change
    add_reference :locations, :worker, index: true
  end
end
