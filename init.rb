# View hook
require_dependency 'weekly_scheduler_sidebar_hook'

Redmine::Plugin.register :weekly_scheduler do
  name 'Weekly Scheduler plugin'
  author 'constXife'
  description 'Plugin for repeating weekly issues'
  version '0.0.1'
  url 'https://github.com/constxife/weekly_scheduler'
  author_url 'https://github.com/constxife'

  requires_redmine version_or_higher: '3.3'

  project_module :weekly_scheduler do
    permission :view_schedule,   weekly_schedules: :show, read: true
    permission :manage_schedule, weekly_schedules: [:new, :edit, :destroy, :update], require: :loggedin
  end
end
