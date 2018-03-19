module RedmineRecurringTasks
  def self.issue_associations
    # it's a associations which should be preserved anyway
    default_associations = ['parent', 'project', 'tracker', 'status', 'author', 'assigned_to', 'fixed_version',
                           'priority', 'category', 'journals', 'visible_journals', 'time_entries', 'changesets',
                           'relations_from', 'relations_to', 'attachments', 'custom_values', 'watchers',
                           'watcher_users', 'recurring_task']

    Issue.reflections.keys.dup - default_associations
  end
end
