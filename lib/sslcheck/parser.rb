module SSLCheck
  class Parser
    class SSLNotConfigured < StandardError; end

    def initialize(raw, url=nil)
      @raw = raw
      @url = url
    end

    def parse
      raise SSLNotConfigured if connection_refused?
      {
        "raw"                 => @raw,
        "valid_certificate"   => valid_certificate?,
        "issued_by"           => issued_by,
        "issued_at"           => issued_at,
        "expires_at"          => expires_at,
        "organizational_unit" => organizational_unit,
        "common_name"         => common_name,
        "issuer_country"      => issuer_country,
        "issuer_state"        => issuer_state,
        "issuer_locality"     => issuer_locality,
        "issuer_organization" => issuer_organization,
        "issuer_common_name"  => issuer_common_name,
      }
    end

    def certs
      @raw.scan(/((?<=-----BEGIN CERTIFICATE-----)(?:\S+|\s(?!-----END CERTIFICATE-----))+(?=\s-----END CERTIFICATE-----))/)
          .flatten
          .map{|cert| "-----BEGIN CERTIFICATE-----\n#{cert.strip}\n-----END CERTIFICATE-----\n" }
    end

    def certificate
      Certificate.new certs.first
    end

    def ca_bundle
      Certificate.new certs[1..certs.size].join("\n")
    end

    def url
      @url
    end

    def issued_by
      certificate.issued_by
    end

    def issued_at
      certificate.not_before
    end

    def expires_at
      certificate.not_after
    end

    def organizational_unit
      certificate.organizational_unit
    end

    def common_name
      certificate.common_name
    end

    def issuer_country
      certificate.issuer_country
    end

    def issuer_state
      certificate.issuer_state
    end

    def issuer_locality
      certificate.issuer_locality
    end

    def issuer_organization
      certificate.issuer_organization
    end

    def issuer_common_name
      certificate.issuer_common_name
    end


  private
    def connection_refused?
      @raw.match("connect: Connection refused")
    end

    def valid_certificate?
      Validator.new(self).validate
    end
  end
end
