# weekly_scheduler

[![Code Climate](https://codeclimate.com/github/constXife/weekly_scheduler/badges/gpa.svg)](https://codeclimate.com/github/constXife/weekly_scheduler)

Plugin is designed to make periodically issues copies for dealing with repetitive tasks

# Installation

* Ruby 2.3+
* Redmine 3.3+
* Standart install plugin:

```
cd {REDMINE_ROOT}
git clone https://github.com/constXife/weekly_scheduler.git plugins/weekly_scheduler
bundle install
bundle exec rake redmine:plugins:migrate RAILS_ENV=production
```

# Run

To run copying issues task you should run rake task

```
cd {REDMINE_ROOT}
bundle exec rake weekly_scheduler:exec
```

And to do it periodically you may use cron or another external scheduler.

# Recommendation

To get all parent issues I'd recommend make new tracker called "Templates", then when you creating new schedule for issue — select specific tracker in form.

# License

[MIT](https://github.com/constxife/weekly_scheduler/blob/master/LICENSE)