module Redirector
  class Engine < ::Rails::Engine
    config.redirector = ActiveSupport::OrderedOptions.new

    endpoint Redirector::Endpoint


    initializer "redirector.apply_options" do |app|
      Redirector.include_query_in_source = app.config.redirector.include_query_in_source || false
      Redirector.preserve_query          = app.config.redirector.preserve_query || false
      Redirector.silence_sql_logs        = app.config.redirector.silence_sql_logs || false
    end

  end
end
