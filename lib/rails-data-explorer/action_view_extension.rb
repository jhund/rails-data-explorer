#
# Adds view helpers to ActionView
#
class RailsDataExplorer
  module ActionViewExtension

    # Renders a spinner while the list is being updated
    def render_explorations(explorations)
      explorations.map { |e| e.render }
    end

  end
end
