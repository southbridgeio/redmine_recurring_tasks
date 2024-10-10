
module RedmineRecurringTasks
  # Class for check which tasks should be copied
  class IssueChecker
    attr_accessor :settings

    # @param [Hash] redmine plugin settings
    def initialize(settings = nil)
      @settings = settings
    end

    # @return [void]
    def call
      schedules.each do |schedule|
        begin
          schedule.execute(settings['associations'])
        rescue RecurringTask::UnauthorizedError => e
          log_error(e)
          next
        rescue => e
          Airbrake.notify(e) if defined?(Airbrake)
          log_error(e)
          next
        end
      end
    end

    # @return [Array<RecurringTask>] a schedules which should be executed
    def schedules
      RecurringTask.schedules
    end

    private

    def log_error(e)
      logger.error e.to_s
      logger.error e.backtrace.join("\n")
    end

    # @return [Logger] a log class
    def logger
      @logger ||= Logger.new(Rails.root.join('log', 'redmine_recurring_tasks.log'))
    end
  end
end
