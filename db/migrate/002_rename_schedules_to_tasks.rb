class RenameSchedulesToTasks < ActiveRecord::Migration
  def change
    rename_table :weekly_schedules, :recurring_tasks
  end
end
