# -*- coding: utf-8 -*-

require 'rails'

class RailsDataExplorer

  # Responsibilities:
  #  * Tie RailsDataExplorer into a Rails app
  #  * Initialize ActionViewExtension
  #  * Tell rails which assets to precompile
  #
  # Collaborators:
  #  * ActiveSupport
  #  * RailsDataExplorer
  #
  class Engine < ::Rails::Engine

    # It's an engine so that we can add javascript and image assets
    # to the asset pipeline.

    isolate_namespace RailsDataExplorer

    # ActiveSupport.on_load :action_controller do
    #   include RailsDataExplorer::ActionControllerExtension
    # end

    ActiveSupport.on_load :action_view do
      include RailsDataExplorer::ActionViewExtension
    end

    # ActiveSupport.on_load :active_record do
    #   extend RailsDataExplorer::ActiveRecordExtension
    # end

    initializer "filterrific" do |app|
      app.config.assets.precompile += %w(
        multiple_bivariate_small.png
      )
    end

  end
end
