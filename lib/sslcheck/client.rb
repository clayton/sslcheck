require 'socket'
require 'openssl'


module SSLCheck
  class Client
    class Response
      attr_accessor :host_name, :peer_cert, :peer_cert_chain, :errors
      alias_method :ca_bundle, :peer_cert_chain

      def initialize
        self.peer_cert = nil
        self.peer_cert_chain = []
        self.errors = []
      end
    end

    def initialize
      @response = Response.new
    end

    def get(url)
      begin
        uri = determine_uri(url)

        sock = TCPSocket.new(uri.host, 443)
        ctx = OpenSSL::SSL::SSLContext.new
        ctx.set_params(verify_mode: OpenSSL::SSL::VERIFY_PEER)

        @socket = OpenSSL::SSL::SSLSocket.new(sock, ctx).tap do |socket|
          socket.sync_close = true
          socket.connect
          @response.host_name = uri.host
          @response.peer_cert = OpenSSL::X509::Certificate.new(socket.peer_cert)
          @response.peer_cert_chain = socket.peer_cert_chain
        end

        @socket.sysclose
      rescue URI::InvalidURIError
        @response.errors << SSLCheck::Errors::Connection::InvalidURI.new({:name => "Invalid URI Error", :type => :invalid_uri, :message => "The URI, #{url}, is not a valid URI."})
      rescue OpenSSL::SSL::SSLError
        @response.errors << SSLCheck::Errors::Connection::SSLVerify.new({:name => "OpenSSL Verification Error", :type => :openssl_error, :message => "There was a peer verification error."})
      end

      @response
    end

    private
      def determine_uri(url)
        return URI.parse(url) if url.match(/^https\:\/\//)
        return URI.parse(url.gsub("http","https")) if url.match(/^http\:\/\//)
        return URI.parse("https://#{url}") if url.match(/^https\:\/\//).nil?
      end
  end
end
