class CreateWorkers < ActiveRecord::Migration
  def change
    create_table :workers do |t|
      t.string :job_id
      t.string :class_name
      t.integer :status
      t.string :error_class_name
      t.string :error_message

      t.timestamps
    end
  end
end
