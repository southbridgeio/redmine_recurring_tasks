namespace :redmine_recurring_tasks do
  desc 'Run issues check'
  task exec: :environment do
    checker = RedmineRecurringTasks::IssueChecker.new(Setting.plugin_redmine_recurring_tasks)
    checker.call
  end
end
