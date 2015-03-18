require 'spec_helper'

module SSLCheck
  describe 'CABundleValidatorSpec' do
    before do
      @cert = Certificate.new(VALID_CERT)
      @ca_bundle = [Certificate.new(CA_PARENT), Certificate.new(CA_GRAND_PARENT), Certificate.new(CA_GREAT_GRAND_PARENT)]
    end
    context "when the CA Bundle verifies the certificate" do
      it 'should return nothing' do
        sut = Validators::CABundle.new("npboards.com", @cert, @ca_bundle)
        result = sut.validate
        expect(result).to_not be
      end
    end
    context "when the certificate cannot be verified by the CA Bundle" do
      it 'should return errors' do
        sut = Validators::CABundle.new("npboards.com", @cert, [Certificate.new(CA_PARENT)])
        result = sut.validate
        expect(result).to be_a SSLCheck::Errors::Validation::CABundleVerification
      end
    end
  end
end
