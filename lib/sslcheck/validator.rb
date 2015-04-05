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
        Validators::ExpirationDate,
        Validators::CABundle,
      ]
    end

    def validate(common_name=nil, peer_cert=nil, ca_bundle=[], validators=[])
      raise CommonNameMissingError if common_name.nil? || common_name.empty?
      raise PeerCertificateMissingError if peer_cert.nil?
      raise CABundleMissingError if ca_bundle.nil? || ca_bundle.empty?
      @common_name = common_name
      @peer_cert = peer_cert
      @ca_bundle = ca_bundle


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
