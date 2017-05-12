# Redmine Recurring Tasks

[![Build Status](https://travis-ci.org/centosadmin/redmine_recurring_tasks.svg?branch=master)](https://travis-ci.org/centosadmin/redmine_recurring_tasks)

Plugin for creating scheduled tasks from templates.

# Installation

* Ruby 2.2+
* Redmine 3.3+
* Standard install plugin:

```
cd {REDMINE_ROOT}
git clone https://github.com/centosadmin/redmine_recurring_tasks.git plugins/redmine_recurring_tasks
bundle install
bundle exec rake redmine:plugins:migrate RAILS_ENV=production
```

# Run

To run copying issues task you should run rake task

```
cd {REDMINE_ROOT}
bundle exec rake redmine_recurring_tasks:exec
```

And to do it periodically you may use cron or another external scheduler.

# Recommendation

To get all parent issues I'd recommend make new tracker called "Templates", then when you creating new schedule for issue — select specific tracker in the form.

# License

[MIT](https://github.com/centosadmin/redmine_recurring_tasks/blob/master/LICENSE)