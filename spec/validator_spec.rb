require 'spec_helper'

module SSLCheck
  describe 'Validator' do
    describe 'Using Validators' do
      before do
        @cert = Certificate.new(VALID_CERT)
        @ca_bundle = [Certificate.new(CA_PARENT), Certificate.new(CA_GRAND_PARENT)]
        @sut = Validator.new
      end
      it 'should validate the certificate with available validators' do
        validator = Validators::GenericValidator

        expect(validator).to receive(:new).and_return(Validators::GenericValidator.new("example.com", @cert, @ca_bundle))
        @sut.validate("example.com", @cert, @ca_bundle, [validator])
      end

      it 'should have default validators' do
        expect(Validators::CommonName).to receive(:new).and_return(Validators::CommonName.new("example.com", @cert, @ca_bundle))
        expect(Validators::IssueDate).to receive(:new).and_return(Validators::IssueDate.new("example.com", @cert, @ca_bundle))
        expect(Validators::ExpirationDate).to receive(:new).and_return(Validators::ExpirationDate.new("example.com", @cert, @ca_bundle))

        @sut.validate("example.com", @cert, @ca_bundle)
      end
    end
    describe 'Validating a Certificate' do
      context "when an expected common name is not supplied" do
        before do
          @sut = Validator.new
        end
        it 'should raise an exception' do
          expect{@sut.validate("", nil, [])}.to raise_exception(Validator::CommonNameMissingError)
        end
      end
      context "when a peer certificate is not supplied" do
        before do
          @sut = Validator.new
        end
        it 'should raise an exception' do
          expect{@sut.validate("www.example.com", nil, [])}.to raise_exception(Validator::PeerCertificateMissingError)
        end
      end
      context "when a CA bundle is not supplied" do
        before do
          @sut = Validator.new
        end
        it 'should raise an exception' do
          expect{@sut.validate("www.example.com", Certificate.new(VALID_CERT), [])}.to raise_exception(Validator::CABundleMissingError)
        end
      end
      context 'when the certificate is valid' do
        before do
          @cert = Certificate.new(VALID_CERT)
          @ca_bundle = [Certificate.new(CA_PARENT), Certificate.new(CA_GRAND_PARENT)]
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
        context "when the certificate was issused to a wildcard domain" do
          it 'should be valid' do
            @cert = Certificate.new(WILDCARD_CERT)
            @ca_bundle = [Certificate.new(CA_PARENT), Certificate.new(CA_GRAND_PARENT)]
            @sut = Validator.new
            @sut.validate("foobar.squarespace.com", @cert, @ca_bundle)

            expect(@sut.valid?).to be
          end
        end
        context "when the certificate has alternate subject names" do
          it 'should allow matches against the supplied common name' do
            @sut.validate("npboards.com", @cert, @ca_bundle)
            expect(@sut.valid?).to be
          end
        end
      end
      xcontext "when the certificate is not valid" do
      end
    end
  end
end
