module ApplicationHelper

  def is_active(action)
    current_page?(:controller => action) ? 'active' : ''
  end
end
