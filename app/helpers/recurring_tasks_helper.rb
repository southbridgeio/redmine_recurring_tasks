module RecurringTasksHelper
  def month_names
    standalone_key = 'date.standalone_month_names'
    I18n.exists?(standalone_key) ? I18n.t(standalone_key) : I18n.t('date.month_names')
  end
end
