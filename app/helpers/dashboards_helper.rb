# Convenience methods consumed in the dashboards controller index view
module DashboardsHelper
  def week_range(date: DateTime.now.in_time_zone, start_day: :monday)
    week_start = date.beginning_of_week start_day
    week_end = date.end_of_week start_day
    week_start_string = week_start.strftime('%B %-d')
    week_end_string = if week_start.month == week_end.month
                        week_end.strftime('%-d')
                      else
                        week_end.strftime('%B %-d')
                      end
    "#{week_start_string} - #{week_end_string}"
  end

  def plus_sign_glyphicon(note)
    return nil unless note && note.try(:full_text).length > 41
    "<span class='glyphicon glyphicon-plus-sign' aria-hidden='true' " \
    "data-toggle='popover' data-placement='bottom' title='Most recent note' " \
    "data-content='#{h note.full_text}'>" \
    "</span><span class='sr-only'>Full note</span>".html_safe
  end

  def display_note_text_for(note)
    return nil unless note.try(:full_text).present?

    "<p><strong>Most recent note from #{h note.created_by.name} " \
    "at #{note.created_at.display_timestamp}:</strong></p>" \
    "<p>#{h note.full_text[0..400]}</p>".html_safe
  end

  def voicemail_options
    enum_text = { not_specified: 'No instructions; no ID VM',
                  no: 'Do not leave a voicemail',
                  yes: 'Voicemail OK' }
    vm_options = Patient::VOICEMAIL_PREFERENCE

    vm_options.map { |option| [enum_text[option], option] }
  end
end
