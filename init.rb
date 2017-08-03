require 'redmine_recurring_tasks'

reloader = defined?(ActiveSupport::Reloader) ? ActiveSupport::Reloader : ActionDispatch::Reloader
reloader.to_prepare do
  paths = '/lib/redmine_recurring_tasks/{patches/*_patch,hooks/*_hook}.rb'
  Dir.glob(File.dirname(__FILE__) + paths).each do |file|
    require_dependency file
  end
end

Redmine::Plugin.register :redmine_recurring_tasks do
  name 'Redmine Recurring Tasks'
  author 'Southbridge'
  description 'Plugin for creating scheduled tasks from template'
  version '0.1.0'
  url 'https://github.com/centosadmin/redmine_recurring_tasks'
  author_url 'https://github.com/centosadmin'

  requires_redmine version_or_higher: '3.3'

  settings(
    default: {
      'associations' => RedmineRecurringTasks.issue_associations
    },
    partial: 'settings/redmine_recurring_tasks'
  )

  project_module :redmine_recurring_tasks do
    permission :view_schedule,   recurring_tasks: :show, read: true
    permission :manage_schedule, recurring_tasks: [:new, :edit, :destroy, :update], require: :loggedin
  end
end
