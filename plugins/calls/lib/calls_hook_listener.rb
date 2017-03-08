class CallsHookListener < Redmine::Hook::ViewListener
  def view_projects_show_left(context = {})
    return content_tag("p", "Custom content added to the left")
  end

  def view_projects_show_right(context = {})
    return content_tag("p", "Custom content added to the right")
  end

  def view_issues_show_description_bottom(context={})
    html = ''
    html << '<p><b>view_issues_show_description_bottom</b></p>'
    return html
  end
  
  def view_issues_context_menu_end(context={})
    html = ''
    html << '<p><b>view_issues_context_menu_end!!!!!</b></p>'
    return html
  end

  def view_custom_fields_form_upper_box(context={})
    html = ''
    html << '<p><b>====view_custom_fields_form_upper_box</b></p>'
    return html
  end

  def view_issues_form_details_bottom(context={})
    html = ''
    html << '<p><b>view_issues_form_details_bottom</b></p>'
    return html
  end

end
