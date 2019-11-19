# Redmine Recurring Tasks

[![Build Status](https://travis-ci.org/southbridgeio/redmine_recurring_tasks.svg?branch=master)](https://travis-ci.org/southbridgeio/redmine_recurring_tasks)

Плагин для запланированного создания задач с шаблонов

# Установка

* Ruby 2.2+
* Redmine 3.3+
* Стандартная установка плагина:

```
cd {REDMINE_ROOT}
git clone https://github.com/southbridgeio/redmine_recurring_tasks.git plugins/redmine_recurring_tasks
bundle install
bundle exec rake redmine:plugins:migrate RAILS_ENV=production
```

# Использование

Чтобы воспользоваться плагином, вам необходимо включить его в настройках модулей проекта. Далее, переходите на страницу задачи
и вы увидите секцию "Расписание" с ссылкой "Добавить".

# Запуск

Чтобы создать запланированные задачи, вам необходимо запустить rake задачу

```
cd {REDMINE_ROOT}
bundle exec rake redmine_recurring_tasks:exec RAILS_ENV=production
```

И чтобы запуск происходил периодически, можно воспользоваться cron или другим планировщиком.

## Планировщики

### Sidekiq-cron

Чтобы запустить sidekiq-cron:

- Установить redis (*yum install redis*)
- Установить плагин [redmine_sidekiq](https://github.com/ogom/redmine_sidekiq)
- Создать файл инициализации. Для примера

```
# /opt/redmine/config/initializers/zz-cron.rb

class RecurringTaskWorker
  include Sidekiq::Worker

  def perform
    checker = RedmineRecurringTasks::IssueChecker.new(Setting.plugin_redmine_recurring_tasks)
    checker.call
  end
end

cron_job_array = [
  {
    'name'  => 'Weekly schedule worker',
    'class' => 'RecurringTaskWorker',
    'cron'  => '*/5 * * * *'
  }
]

Sidekiq::Cron::Job.load_from_array cron_job_array
```

### Whenever

```
cd {REDMINE_ROOT}
whenever --update-crontab --load-file plugins/redmine_recurring_tasks/config/schedule.rb
```

### Cron manual

```
$ crontab -e
```

Добавляем строку с cron job

```
*/5 * * * * /bin/bash -l -c 'cd /home/redmine && RAILS_ENV=production bundle exec rake redmine_recurring_tasks:exec'
```

# Настройки

Если у вас есть какие-то другие плагины, которые по каким-то причинам не копируются в задачи, то
вы можете указать связи для копирования в настройках плагина. Внимание! Эти опции могут сломать работу плагина.

Для примера, если вы используете *Redmine checklists*, вы можете выделить "checklists" в настройках. 

# Лицензия

[MIT](https://github.com/southbridgeio/redmine_recurring_tasks/blob/master/LICENSE)

# Автор плагина

Плагин разработан [Southbridge](https://southbridge.io)
