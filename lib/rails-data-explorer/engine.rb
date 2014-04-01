require 'rails'

class RailsDataExplorer
  class Engine < ::Rails::Engine

    # It's an engine so that we can add javascript and image assets
    # to the asset pipeline.

    # initializer "rails-data-explorer.active_record_extension" do |app|
    #   require 'rails-data-explorer/active_record_extension'
    #   class ::ActiveRecord::Base
    #     extend RailsDataExplorer::ActiveRecordExtension::ClassMethods
    #   end
    # end

    # initializer "rails-data-explorer.action_view_extension" do |app|
    #   require 'rails-data-explorer/action_view_extension'
    #   class ::ActionView::Base
    #     include RailsDataExplorer::ActionViewExtension
    #   end
    # end

  end
end
