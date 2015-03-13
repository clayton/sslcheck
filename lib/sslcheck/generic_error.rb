module SSLCheck
  class GenericError
    attr_accessor :type, :message
    def initialize(opts={})
      self.type    = opts[:type]
      self.message = opts[:message]
    end
  end
end
