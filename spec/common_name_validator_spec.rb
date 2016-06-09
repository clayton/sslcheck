require 'spec_helper'

module SSLCheck
  describe 'CommonNameValidatorSpec' do
    before do
      @cert = Certificate.new(VALID_CERT)
      @ca_bundle = [Certificate.new(CA_PARENT), Certificate.new(CA_GRAND_PARENT)]
    end
    context "when the common name is valid" do
      it 'should return nothing' do
        sut = Validators::CommonName.new("letsencrypt.org", @cert, @ca_bundle)
        result = sut.validate
        expect(result).to_not be
      end
      context "when the certificate was issued to a wildcard domain" do
        it 'should return nothing' do
          wildcard_cert = Certificate.new(WILDCARD_CERT)
          sut = Validators::CommonName.new("example.squarespace.com", wildcard_cert, @ca_bundle)
          result = sut.validate
          expect(result).to_not be
        end
      end
      context "when the certificate has alternate subject names" do
        it 'should allow matches against the supplied common name' do
          sut = Validators::CommonName.new("letsencrypt.org", @cert, @ca_bundle)
          result = sut.validate
          expect(result).to_not be
        end
      end
    end
    context "when the common name is mismatched" do
      it 'should return errors' do
        sut = Validators::CommonName.new("example.com", @cert, @ca_bundle)
        result = sut.validate
        expect(result).to be_a SSLCheck::Errors::Validation::CommonNameMismatch
      end
    end
    context "When not a wildcard domain" do

      context "and part of the common name matches" do
        @cert = Certificate.new(APP_SSL_INSIGHT_CERT)
        @ca_bundle = [Certificate.new(CA_PARENT), Certificate.new(CA_GRAND_PARENT)]
        it 'should return errors' do
          sut = Validators::CommonName.new("mismatch.examples.sslinsight.com", @cert, @ca_bundle)
          result = sut.validate
          expect(result).to be_a SSLCheck::Errors::Validation::CommonNameMismatch
        end
      end
    end

  end
end
