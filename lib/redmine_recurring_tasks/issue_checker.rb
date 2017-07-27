
module RedmineRecurringTasks
  # Class for check which tasks should be copied
  class IssueChecker
    attr_accessor :settings

    # @param [Hash] redmine plugin settings
    def initialize(settings = nil)
      @settings = settings
    end

    # @return [Array<RecurringTask>] a schedules which should be executed
    def schedules
      RecurringTask.schedules
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
