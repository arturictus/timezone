module Timezone
  # TimezoneHTTPWrapper
  # Fixes a strong error we were having with sidekiq.
  # It was crashing all sidekiq
  class HTTPWrappers
    attr_reader :domain
    def initialize(protocol, host)
      @domain = URI.parse("#{protocol}://#{host}")
    end

    def get(path)
      url = _url(path)
      if Timezone.http_wrapper == 'celluloid_http'
        CelluloidHTTP.new(self).get(url)
      else
        HTTP.get(url)
      end
    end

    private

    def _url(str)
      URI.parse("#{domain}/#{str}").to_s
    end

    class CelluloidHTTP
      include Celluloid::IO
      attr_reader :context
      def initialize(context)
        @context = context
      end
      def get(url)
        # TODO add Protocol selector
        HTTP.get(url, socket_class: Celluloid::IO::TCPSocket,
                  ssl_socket_class: Celluloid::IO::SSLSocket)
      end
    end
  end
end
