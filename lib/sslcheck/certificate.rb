require 'openssl'

module SSLCheck
  class Certificate
    def initialize(cert, clock=nil)
      @cert = bootstrap_certificate(cert)
      @clock = clock || DateTime
    end

    def to_h
      {
        :common_name       => common_name,
        :organization_unit => organizational_unit,
        :not_before        => not_before,
        :not_after         => not_after,
        :issued            => true,
        :expired           => false,
        :issuer            => {
          :common_name  => issuer_common_name,
          :country      => issuer_country,
          :state        => issuer_state,
          :locality     => issuer_locality,
          :organization => issuer_organization
        }
      }
    end

    def to_s
      @cert.to_s
    end

    def subject
      @cert.subject.to_s
    end

    def organizational_unit
      match = subject.match(/OU=([\w\s]+)/)
      match.captures.first if match
    end

    def common_name
      subject.scan(/CN=(.*)/)[0][0]
    end

    def alternate_common_names
      ext = @cert.extensions.find{|ext| ext.oid == "subjectAltName" }
      return [] unless ext
      alternates = ext.value.split(",")
      names = alternates.map{|a| a.scan(/DNS:(.*)/)[0][0]}
      names
    end

    def issuer
      @cert.issuer.to_s
    end

    def issuer_country
      match = issuer.match(/C=([\w\s]+)/)
      match.captures.first if match
    end

    def issuer_state
      match = issuer.match(/ST=([\w\s]+)/)
      match.captures.first if match
    end

    def issuer_locality
      match = issuer.match(/L=([\w\s]+)/)
      match.captures.first if match
    end

    def issuer_organization
      match = issuer.match(/O=([^\/]+)/)
      match.captures.first if match
    end

    def issuer_common_name
      issued_by
    end

    def issued_by
      match = issuer.match("CN=(.*)")
      match.captures.first if match
    end

    def public_key
      @cert.public_key
    end

    def verify(ca)
      @cert.verify(ca.public_key)
    end

    def not_before
      DateTime.parse(@cert.not_before.to_s)
    end

    def not_after
      DateTime.parse(@cert.not_after.to_s)
    end

    def expired?
      @clock.now > not_after
    end

    def issued?
      @clock.now > not_before
    end

    def bootstrap_certificate(cert)
      return cert if cert.is_a?(OpenSSL::X509::Certificate)
      return cert if cert.is_a?(SSLCheck::Certificate)
      OpenSSL::X509::Certificate.new cert
    end

  end
end
