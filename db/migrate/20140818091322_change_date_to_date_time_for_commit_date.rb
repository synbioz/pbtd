class ChangeDateToDateTimeForCommitDate < ActiveRecord::Migration
  def change
    change_column :commits, :commit_date, :datetime
  end
end
