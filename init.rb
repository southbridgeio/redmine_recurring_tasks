# View hook
require_dependency 'redmine_recurring_tasks/hooks/issue_sidebar_hook'

Redmine::Plugin.register :redmine_recurring_tasks do
  name 'Redmine Recurring Tasks'
  author 'southbridge'
  description 'Plugin for creating scheduled tasks from template.'
  version '0.0.2'
  url 'https://github.com/centosadmin/redmine_recurring_tasks'
  author_url 'https://github.com/centosadmin'

  requires_redmine version_or_higher: '3.3'

  project_module :redmine_recurring_tasks do
    permission :view_schedule,   weekly_schedules: :show, read: true
    permission :manage_schedule, weekly_schedules: [:new, :edit, :destroy, :update], require: :loggedin
  end
end
