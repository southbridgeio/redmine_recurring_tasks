# 0.3.4

* Add Translation Into Brazilian Portuguese
* Fix time zone issue

# 0.3.3

* Fix schedule creation

# 0.3.2

* Assign Time.now to copy start_date regardless of due_date presence

# 0.3.1

* Add copy status setting

# 0.3.0

* Improve errors handling
* Adapt for Redmine 4

# 0.2.3

* Use Redmine 3.4-stable in travis with Ruby 2.3 and different time zones
* Use only deep_cloneable to copy issues 

# 0.2.2

* Fix schedule section on issue page
* Fix time chek for DST
* Fix constants loading issue

# 0.2.1

* Copying issues only from active project
* Plugin association removed from settings
* Add warning in plugin settings page
* Add Russian readme

# 0.2.0

* Fix UTC-related issues
* Add setting for anonymous user usage

# 0.1.0

* Add logging errors via logger
* Add ability to choose months and month days
* Change model from WeeklySchedule to RecurringTask
* Fix schedule checking method
* Move schedule to issue details bottom

# 0.0.2

* **(breaking-change)** Rename plugin to RedmineRecurringTasks
* **(breaking-change)** Transfer plugin to Southbridge (http://github.com/centosadmin)
* Make preserve author of issue on copy
* Add relation between Issue and WeeklySchedule 
* Add issue associations to copy in settings
* If issue have due_date then copied issue have relative due_date
* Add watchers to copied issue

# 0.0.1

* Add ability to make issues copies
