class WeeklySchedule < ActiveRecord::Base
  unloadable

  belongs_to :issue
  belongs_to :tracker

  validates :issue_id, uniqueness: true

  DAYS = %w(monday tuesday wednesday thursday friday saturday sunday).freeze

  def days
    DAYS.select{|d| public_send(d)}
  end
end
