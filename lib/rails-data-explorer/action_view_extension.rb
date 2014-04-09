#
# Adds view helpers to ActionView
#
class RailsDataExplorer
  module ActionViewExtension

    def render_explorations(explorations)
      explorations.map { |e| e.render }
    end

  end
end
