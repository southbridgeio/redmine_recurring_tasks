namespace :redmine_recurring_tasks do
  desc 'Run issues check'
  task exec: :environment do
    RedmineRecurringTasks::IssueChecker.call
  end
end
