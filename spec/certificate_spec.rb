require 'spec_helper'

module SSLCheck
  describe Certificate do
    before(:each) do
      @sut = Certificate.new(VALID_CERT)
    end
    describe 'to_h' do
      it 'should easily turn into a hash' do
        clock = class_double(DateTime, :now => DateTime.parse("2014-12-31 00:00:00"))
        sut = Certificate.new(VALID_CERT, clock)
        actual_hash = sut.to_h
        expected_hash = {
          :common_name       => "www.npboards.com",
          :organization_unit => "Domain Control Validated",
          :not_before        => DateTime.parse("Tue, 17 Jun 2014 18:16:01 +0000"),
          :not_after         => DateTime.parse("Tue, 17 Jun 2015 18:16:01 +0000"),
          :issued            => true,
          :expired           => false,
          :issuer            => {
            :common_name  => "Go Daddy Secure Certificate Authority - G2",
            :country      => "US",
            :state        => "Arizona",
            :locality     => "Scottsdale",
            :organization => "GoDaddy.com, Inc."
          }
        }

        expect(actual_hash).to eq(expected_hash)
      end
    end
    describe "subject" do
      it "should expose the certificate's subject" do
        expect(@sut.subject).to eq "/OU=Domain Control Validated/CN=www.npboards.com"
      end
      it "should expose the common name on the certificate" do
        expect(@sut.common_name).to eq "www.npboards.com"
      end
      it "should expose the organizational unit on the certificate" do
        expect(@sut.organizational_unit).to eq "Domain Control Validated"
      end
    end
    describe "issuer" do
      it "should expose the certificate's issuer" do
        expect(@sut.issuer).to eq "/C=US/ST=Arizona/L=Scottsdale/O=GoDaddy.com, Inc./OU=http://certs.godaddy.com/repository//CN=Go Daddy Secure Certificate Authority - G2"
      end
      it "should expose a friendly version of the issuer" do
        expect(@sut.issued_by).to eq "Go Daddy Secure Certificate Authority - G2"
      end
      it "should expose the issuer's country" do
        expect(@sut.issuer_country).to eq "US"
      end
      it "should expose the issuer's state" do
        expect(@sut.issuer_state).to eq "Arizona"
      end
      it "should expose the issuer's locality" do
        expect(@sut.issuer_locality).to eq "Scottsdale"
      end
      it "should expose the issuer's organization" do
        expect(@sut.issuer_organization).to eq "GoDaddy.com, Inc."
      end
      it "should expose the issuer's common name" do
        expect(@sut.issuer_common_name).to eq "Go Daddy Secure Certificate Authority - G2"
      end
    end
    describe "public key" do
      it "should expose the certificate's public key" do
        expect(@sut.public_key).to be_a OpenSSL::PKey::RSA
      end
    end
    describe "verify" do
      it "should be able to verify a certificate with the public key of another" do
        ca_bundle = Certificate.new(CA_BUNDLE)
        expect(@sut.verify(ca_bundle)).to be
      end
    end
    describe "dates" do
      it "should expose the certificate's issue date" do
        expect(@sut.not_before).to eq DateTime.parse("Tue, 17 Jun 2014 18:16:01 +0000")
      end
      it "should expose the certificate's expiry date" do
        expect(@sut.not_after).to eq DateTime.parse("Tue, 17 Jun 2015 18:16:01 +0000")
      end
    end
    describe "expired?" do
      it "should know if it has expired" do
        clock = class_double(DateTime, :now => DateTime.parse("3000-01-01 00:00:00"))
        @sut = Certificate.new(VALID_CERT, clock)
        expect(@sut.expired?).to be
      end
    end
    describe "issued?" do
      it "should know if it has been issued" do
        clock = class_double(DateTime, :now => DateTime.parse("3000-01-01 00:00:00"))
        @sut = Certificate.new(VALID_CERT, clock)
        expect(@sut.issued?).to be
      end
    end
  end
end
