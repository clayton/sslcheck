require 'spec_helper'

module SSLCheck
  describe 'Validator' do
    describe 'Validating a Certificate' do
      context "when an expected common name is not supplied" do
        before do
          @sut = Validator.new
          @sut.validate("", nil, [])
        end
        it 'should not be valid' do
          expect(@sut.valid?).to_not be
        end
        it 'should have errors' do
          expect(@sut.errors).to_not be_empty
          expect(@sut.errors.map{|e| e.class }).to include(Validator::CommonNameMissingError)
        end
      end
      context 'when the certificate is valid' do
        before do
          @cert = OpenSSL::X509::Certificate.new(VALID_CERT)
          @ca_bundle = [OpenSSL::X509::Certificate.new(CA_PARENT), OpenSSL::X509::Certificate.new(CA_GRAND_PARENT)]
          @sut = Validator.new
        end

        it 'should be valid' do
          @sut.validate("www.npboards.com", @cert, @ca_bundle)
          expect(@sut.valid?).to be
        end

        it 'should have no errors' do
          @sut.validate("www.npboards.com", @cert, @ca_bundle)
          expect(@sut.errors).to be_empty
        end

        it 'should have no warnings' do
          @sut.validate("www.npboards.com", @cert, @ca_bundle)
          expect(@sut.warnings).to be_empty
        end
      end
      context "when the certificate is not valid" do
        context "when the common name is mismatched" do
          before do
            @cert = OpenSSL::X509::Certificate.new(VALID_CERT)
            @ca_bundle = [OpenSSL::X509::Certificate.new(CA_PARENT), OpenSSL::X509::Certificate.new(CA_GRAND_PARENT)]
            @sut = Validator.new
          end
          xit 'should not be valid' do
            @sut.validate("example.com", @cert, @ca_bundle)
            expect(@sut.valid?).to_not be
          end
        end
      end
    end
  end
end
