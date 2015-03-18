module SSLCheck
  class Check
    attr_accessor :peer_cert, :ca_bundle, :host_name
    def initialize(client=nil, validator=nil)
      @client = client || Client.new
      @validator = validator || Validator.new
      @errors = []
      @checked = false
    end

    def check(url)
      fetch(url)
      validate if no_errors?
      @checked = true
      return self
    end

    def errors
      @errors
    end

    def failed?
      return false if no_errors?
      true
    end

    def valid?
      return true if no_errors? && checked?
      false
    end

    def checked?
      return true if @checked
      false
    end

  private

    def no_errors?
      @errors.empty?
    end

    def fetch(url)
      response = @client.get(url)
      self.peer_cert = response.peer_cert
      self.ca_bundle = response.ca_bundle
      self.host_name = response.host_name

      response.errors.each do |error|
        @errors << error
      end
      true
    end

    def validate
      @validator.validate(host_name, peer_cert, ca_bundle)
      true
    end
  end
end
