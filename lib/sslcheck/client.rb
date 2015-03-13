require 'socket'
require 'openssl'


module SSLCheck
  class Client
    class Response
      attr_accessor :peer_cert, :peer_cert_chain, :errors
      alias_method :ca_bundle, :peer_cert_chain

      def initialize
        self.peer_cert = nil
        self.peer_cert_chain = []
        self.errors = []
      end
    end

    class Error < SSLCheck::GenericError; end

    def initialize
      @response = Response.new
    end

    def get(url)
      begin
        uri = URI.parse(url)

        sock = TCPSocket.new(uri.host, 443)
        ctx = OpenSSL::SSL::SSLContext.new
        ctx.set_params(verify_mode: OpenSSL::SSL::VERIFY_PEER)

        @socket = OpenSSL::SSL::SSLSocket.new(sock, ctx).tap do |socket|
          socket.sync_close = true
          socket.connect
          @response.peer_cert = OpenSSL::X509::Certificate.new(socket.peer_cert)
          @response.peer_cert_chain = socket.peer_cert_chain
        end

        @socket.sysclose
      rescue URI::InvalidURIError
        @response.errors << Error.new({:type => :invalid_uri, :message => "The URI, #{url}, is not a valid URI."})
      rescue OpenSSL::SSL::SSLError
        @response.errors << Error.new({:type => :openssl_error, :message => "There was a peer verification error."})
      end

      @response
    end
  end
end
