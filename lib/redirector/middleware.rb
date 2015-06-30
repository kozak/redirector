module Redirector

  class Middleware
    attr_reader :application

    def initialize(application)
      @application = application
    end

    def call(environment)
      Redirector::Responder.new(environment).response do
        application.call(environment)
      end
    end

  end
end
