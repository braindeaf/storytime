module ActionDispatch
  module Routing
    class RouteSet

      if Rails::VERSION::MAJOR == 4 && Rails::VERSION::MINOR == 1
        def url_for_with_storytime(options = {})
          Storytime::PostUrlHandler.handle_url(options)
          url_for_without_storytime(options)
        end
      else
        def url_for_with_storytime(options, route_name = nil, url_strategy = UNKNOWN)
          Storytime::PostUrlHandler.handle_url(options)
          url_for_without_storytime(options, route_name, url_strategy)
        end
      end

      alias_method_chain :url_for, :storytime

    end
  end
end
