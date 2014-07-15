class CreateCommits < ActiveRecord::Migration
  def change
    create_table :commits do |t|
      t.references :location, index: true
      t.string :name
      t.string :sha1
      t.string :user
      t.date :commit_date

      t.timestamps
    end
  end
end
