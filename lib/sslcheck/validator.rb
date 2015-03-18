require 'openssl'

module SSLCheck
  class Validator
    class CommonNameMissingError < ArgumentError;end
    class PeerCertificateMissingError < ArgumentError;end
    class CABundleMissingError < ArgumentError;end

    def initialize
      @valid       = false
      @errors      = []
      @warnings    = []
      @common_name = nil
      @peer_cert   = nil
      @ca_bundle   = []
      @validated   = false
      @default_validators = [
        Validators::CommonName,
        Validators::IssueDate,
      ]
    end

    def validate(common_name=nil, peer_cert=nil, ca_bundle=[], validators=[])
      raise CommonNameMissingError if common_name.nil? || common_name.empty?
      raise PeerCertificateMissingError if peer_cert.nil?
      raise CABundleMissingError if ca_bundle.nil? || ca_bundle.empty?
      @common_name = common_name
      @peer_cert = peer_cert

      run_validations(validators)
    end

    def valid?
      @validated && errors.empty?
    end

    def errors
      @errors.compact
    end

    def warnings
      []
    end

  private
    def run_validations(validators)
      validators = @default_validators if validators.empty?
      validators.each do |validator|
        @errors << validator.new(@common_name, @peer_cert, @ca_bundle).validate
      end
      @validated = true
    end

  end
end

  #   class InvalidCertificate < StandardError;end
  #   class InvalidCommonName < StandardError;end
  #   class InvalidDates < StandardError;end
  #   class MissingCACertificate < StandardError;end

  #   def initialize(parser=nil)
  #     @parser = parser
  #     @url = parser.url
  #   end

  #   def validate
  #     raise InvalidCertificate unless validate_certificates
  #     raise InvalidCommonName, "expected #{@url} but got #{certificate.common_name}" unless validate_common_name
  #     raise InvalidDates, "Issued On: #{certificate.not_before}, Expires On: #{certificate.not_after}" unless validate_dates
  #     true
  #   end

  #   def validate_certificates
  #     certificate.verify(ca_bundle)
  #   end

  #   def validate_common_name
  #     matching_wildcard_domain || certificate.common_name.downcase == @url.downcase
  #   end

  #   def validate_expiration_date
  #     !certificate.expired?
  #   end

  #   def validate_issue_date
  #     certificate.issued?
  #   end

  #   def validate_dates
  #     validate_expiration_date && validate_issue_date
  #   end

  # private
  #   def certificate
  #     @parser.certificate
  #   end

  #   def matching_wildcard_domain
  #     true if (certificate.common_name.match(/\*\./) && @url.include?(certificate.common_name.gsub(/\*\./,'')))
  #   end

  #   def ca_bundle
  #     begin
  #       @parser.ca_bundle
  #     rescue OpenSSL::X509::CertificateError => e
  #       raise MissingCACertificate
  #     end
  #   end
