ActionDispatch::Callbacks.to_prepare do
  paths = '/lib/redmine_recurring_tasks/{patches/*_patch,hooks/*_hook}.rb'
  Dir.glob(File.dirname(__FILE__) + paths).each do |file|
    require_dependency file
  end
end

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
