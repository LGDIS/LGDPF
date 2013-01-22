module ApplicationHelper
  def error_messages_for(*objects)
    html = ""
    objects = objects.map {|o| o.is_a?(String) ? instance_variable_get("@#{o}") : o}.compact
    errors = objects.map {|o| o.errors.full_messages}.flatten
    if errors.any?
      html << "<div class='error'><ul>\n"
      errors.each do |error|
        html << "<li>#{h error}</li>\n"
      end
      html << "</ul></div>\n"
    end
    html.html_safe
  end 
end
