#
# Adds view helpers to ActionView
#
module RailsDataExplorer::ActionViewExtension

  # Renders a spinner while the list is being updated
  def render_explorations(explorations)
    explorations.map { |e| e.render }
  end

end
