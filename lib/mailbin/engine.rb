require "importmap-rails"
require "turbo-rails"

module Mailbin
  class Engine < ::Rails::Engine
    isolate_namespace Mailbin

    initializer "mailbin.add_delivery_method" do
      ActiveSupport.on_load :action_mailer do
        ActionMailer::Base.add_delivery_method(
          :mailbin,
          Mailbin::DeliveryMethod,
          location: Rails.root.join("tmp", "mailbin")
        )
      end
    end

    initializer "mailbin.assets" do |app|
      if app.config.respond_to?(:assets)
        app.config.assets.paths << root.join("app/assets/stylesheets")
        app.config.assets.paths << root.join("app/javascript")
        app.config.assets.precompile += %w[ mailbin_manifest ]
      end
    end

    initializer "mailbin.importmap", before: "importmap" do |app|
      Mailbin.importmap.draw root.join("config/importmap.rb")
      Mailbin.importmap.cache_sweeper watches: root.join("app/javascript")

      ActiveSupport.on_load(:action_controller_base) do
        before_action { Mailbin.importmap.cache_sweeper.execute_if_updated }
      end
    end
  end
end
