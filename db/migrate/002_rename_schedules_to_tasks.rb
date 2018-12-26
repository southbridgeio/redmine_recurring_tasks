class RenameSchedulesToTasks < Rails.version < '5.0' ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]
  def change
    rename_table :weekly_schedules, :recurring_tasks
  end
end
