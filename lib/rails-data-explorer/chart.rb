class RailsDataExplorer
  class Chart

    attr_accessor :output_buffer # required for content_tag
    include ActionView::Helpers::TagHelper

    def dom_id
      "rde-chart-#{ object_id }"
    end

  end
end
