class RailsDataExplorer
  class Chart

    include ActionView::Helpers::NumberHelper
    attr_accessor :output_buffer # required for content_tag
    include ActionView::Helpers::TagHelper

    def dom_id
      "rde-chart-#{ object_id }"
    end

    # Returns true if this chart will be rendered. Sometimes we can't make that
    # decision until render time. Override this method in sub classes, e.g.,
    # to avoid rendering ParallelCoordinates when all data series are categorical.
    def render?
      true
    end

  end
end
