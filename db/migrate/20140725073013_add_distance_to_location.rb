class AddDistanceToLocation < ActiveRecord::Migration
  def change
    add_column :locations, :distance, :integer
  end
end
