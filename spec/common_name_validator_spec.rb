require 'spec_helper'

module SSLCheck
  describe 'CommonNameValidatorSpec' do
    before do
      @cert = Certificate.new(VALID_CERT)
      @ca_bundle = [Certificate.new(CA_PARENT), Certificate.new(CA_GRAND_PARENT)]
    end
    context "when the common name is valid" do
      it 'should return nothing' do
        sut = Validators::CommonName.new("npboards.com", @cert, @ca_bundle)
        result = sut.validate
        expect(result).to_not be
      end
    end
    context "when the common name is mismatched" do
      it 'should return errors' do
        sut = Validators::CommonName.new("example.com", @cert, @ca_bundle)
        result = sut.validate
        expect(result).to be_a SSLCheck::Errors::CommonNameMismatch
      end
    end
  end
end
