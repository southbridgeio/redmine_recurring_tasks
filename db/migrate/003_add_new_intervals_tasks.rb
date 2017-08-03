class AddNewIntervalsTasks < ActiveRecord::Migration
  def change
    change_table :recurring_tasks do |t|
      t.string :months,     default: (1..12).to_a.map(&:to_s).to_json, null: false
      t.string :month_days, default: '[]'
    end
  end
end
