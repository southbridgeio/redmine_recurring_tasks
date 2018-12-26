class CreateWeeklySchedules < Rails.version < '5.0' ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]
  def change
    create_table :weekly_schedules do |t|
      t.integer  :issue_id,   null: false, index: true
      t.integer  :tracker_id, null: false, index: true
      t.boolean  :sunday,     default: false, null: false
      t.boolean  :monday,     default: false, null: false
      t.boolean  :tuesday,    default: false, null: false
      t.boolean  :wednesday,  default: false, null: false
      t.boolean  :thursday,   default: false, null: false
      t.boolean  :friday,     default: false, null: false
      t.boolean  :saturday,   default: false, null: false
      t.time     :time,       default: '2017-01-01 00:00:00', null: false
      t.datetime :last_try_at

      t.timestamps null: false
    end
  end
end
