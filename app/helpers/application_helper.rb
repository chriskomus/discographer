module ApplicationHelper

  def is_active(action)
    current_page?(:controller => action) ? 'active' : ''
  end
  #
  # def is_active_controller(controller)
  #   current_page?(:controller => controller) ? 'active' : ''
  # end

end
