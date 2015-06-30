
module Redirector
  class Endpoint

    def self.call(env)
      responder(env).response do
        [404, {'X-Cascade'=>'pass'}, '']
      end
    end

    protected

    def self.responder(env)
      Redirector::Responder.new(env)
    end

  end
end
