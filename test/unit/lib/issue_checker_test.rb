require File.expand_path('../../../test_helper', __FILE__)

class RecurringTaskTest < ActiveSupport::TestCase
  def test_full_days
    recurring_task = RecurringTask.new
    assert recurring_task.days, RecurringTask::DAYS
  end

  def test_partial_days
    recurring_task = RecurringTask.new
    recurring_task.monday = true
    assert recurring_task.days, RecurringTask::DAYS.dup.delete('monday')
  end
end
