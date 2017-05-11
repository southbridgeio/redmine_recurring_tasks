Redmine::Plugin.register :weekly_scheduler do
  name 'Weekly Scheduler plugin'
  author 'constXife'
  description 'Plugin for repeating weekly issues'
  version '0.0.1'
  url 'https://github.com/constxife/weekly_scheduler'
  author_url 'https://github.com/constxife'

  requires_redmine version_or_higher: '3.0'

  project_module :weekly_scheduler do
    permission :view_schedule,   scheduler: :index
    permission :manage_schedule, scheduler: :manage
  end
end
