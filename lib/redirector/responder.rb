module Redirector
  class Responder

    attr_reader :env, :request
    # responds to destination_for, and match_for
    attr_writer :matcher

    def initialize(environment)
      @env = environment
      @request = Rack::Request.new(environment)
    end

    def response(&default)
      if redirect?
        redirect_response
      else
        default.call if block_given?
      end
    end

    private

    def matcher
      @matcher || RedirectRule
    end

    def redirect?
      matched_destination.present?
    end

    def matched_destination
      @matched_destination ||= with_optional_silencing do
        matcher.destination_for(request_path, env)
      end
    end

    def with_optional_silencing(&block)
      if Redirector.silence_sql_logs
        ActiveRecord::Base.logger.silence { yield }
      else
        yield
      end
    end

    def request_path
      if Redirector.include_query_in_source
        env['ORIGINAL_FULLPATH']
      else
        request.path
      end
    end

    def redirect_response
      [301, {'Location' => redirect_url_string},
        [%{You are being redirected <a href="#{redirect_url_string}">#{redirect_url_string}</a>}]]
    end

    def destination_uri
      URI.parse(matched_destination)
    rescue URI::InvalidURIError
      rule = matcher.match_for(request_path, env)
      raise Redirector::RuleError, "RedirectRule #{rule.id} generated the bad destination: #{matched_destination}"
    end

    def redirect_uri
      destination_uri.tap do |uri|
        uri.scheme ||= 'http'
        uri.host   ||= request.host
        uri.port   ||= request.port if port_in_url?
        uri.query  ||= request.query_string if Redirector.preserve_query
      end
    end

    def redirect_url_string
      @redirect_url_string ||= redirect_uri.to_s
    end

    def port_in_url?
     scheme = request.scheme
     port = request.port
     if scheme == "https" && port != 443 || scheme == "http" && port != 80
       return true
     else
       return false
     end
    end
  end
end
