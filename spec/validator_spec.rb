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
        expect(Validators::CABundle).to receive(:new).and_return(Validators::CABundle.new("example.com", @cert, @ca_bundle))

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
          @ca_bundle = [Certificate.new(CA_PARENT), Certificate.new(CA_GRAND_PARENT), Certificate.new(CA_GREAT_GRAND_PARENT)]
          @sut = Validator.new
          @validators = [PassThroughValidator]
        end

        it 'should be valid' do
          @sut.validate("www.npboards.com", @cert, @ca_bundle, @validators)
          expect(@sut.valid?).to be

        end

        it 'should have no errors' do
          @sut.validate("www.npboards.com", @cert, @ca_bundle, @validators)
          expect(@sut.errors).to be_empty
        end

        it 'should have no warnings' do
          @sut.validate("www.npboards.com", @cert, @ca_bundle, @validators)
          expect(@sut.warnings).to be_empty
        end
      end
    end
  end
end

class PassThroughValidator < SSLCheck::Validators::GenericValidator
  def validate
    nil
  end
end
