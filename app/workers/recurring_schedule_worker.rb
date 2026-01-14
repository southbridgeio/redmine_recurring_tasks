class RecurringScheduleWorker
  include Sidekiq::Worker

  def perform
    RedmineRecurringTasks::IssueChecker.new(Setting.plugin_redmine_recurring_tasks).call
  end
end
