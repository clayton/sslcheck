module SSLCheck
  class ValidationError
    attr_accessor :name, :message
    def initialize(opts={})
      self.name = opts[:name]
      self.message = opts[:message]
    end

    def to_s
      "[#{self.name}] #{self.message}"
    end
  end
end
