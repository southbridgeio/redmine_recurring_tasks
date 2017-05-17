
module RedmineRecurringTasks
  # Class for check which tasks should be copied
  class IssueChecker
    attr_accessor :settings

    # @param [Hash] redmine plugin settings
    def initialize(settings = nil)
      @settings = settings
    end

    # @return [Array<WeeklySchedule>] a schedules which should be executed
    def schedules
      date = Time.now
      week_day = date.strftime('%A').downcase

      WeeklySchedule.where("#{week_day} = true").map do |schedule|
        time_came = schedule.time.strftime('%H%M%S') <= date.strftime('%H%M%S')

        if time_came && (schedule.last_try_at.nil? || schedule.last_try_at.strftime('%Y%m%d') < date.strftime('%Y%m%d'))
          schedule
        end
      end.compact
    end

    # @return [void]
    def call
      schedules.each do |schedule|
        begin
          schedule.execute(settings['associations'])
        rescue => e
          puts e.to_s
          puts e.backtrace.join("\n")
          next
        end
      end
    end
  end
end
