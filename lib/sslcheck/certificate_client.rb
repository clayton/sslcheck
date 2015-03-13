require 'uri'

module SSLCheck
  class CertificateClient
    def fetch(url)
      uri = URI.parse(url)
      `bash -c '(sleep 5; kill $$) & exec openssl s_client -showcerts -connect #{uri.to_s}:443 < /dev/null'`
    end
  end
end
