require 'spec_helper'

module SSLCheck
  describe 'ExpirationDateValidatorSpec' do
    before do
      @cert = Certificate.new(VALID_CERT)
      @ca_bundle = [Certificate.new(CA_PARENT), Certificate.new(CA_GRAND_PARENT)]
    end
    context "when the expiration date is in the future" do
      it 'should return errors' do
        sut = Validators::ExpirationDate.new("npboards.com", @cert, @ca_bundle)
        result = sut.validate(FutureClock.new)
        expect(result).to be_a SSLCheck::Errors::Validation::CertificateExpired
      end
    end
    context "when the expiration date is in the past" do
      it 'should return nothing' do
        sut = Validators::ExpirationDate.new("npboards.com", @cert, @ca_bundle)
        result = sut.validate(PastClock.new)
        expect(result).to_not be
      end
    end
  end
end

class FutureClock
  def now
    DateTime.parse("3000-01-01 00:00:00")
  end
end

class PastClock
  def now
    DateTime.parse("1000-01-01 00:00:00")
  end
end
