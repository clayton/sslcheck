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
    describe 'extensions' do
      describe 'Subject Alternate Name' do
        context "when it has as subject alternate name extension" do
          it 'should expose the altername names as alternate common names' do
            sut = Certificate.new(VALID_CERT)

            expect(sut.alternate_common_names).to include("www.npboards.com")
            expect(sut.alternate_common_names).to include("npboards.com")
          end
        end
        context "when it only has one alternate name in the extension" do
          it 'should expose only that name' do
            ext = OpenSSL::X509::Extension.new "subjectAltName", "DNS:example.com"
            cert = OpenSSL::X509::Certificate.new VALID_CERT

            allow(cert).to receive(:extensions).and_return [ext]
            sut = Certificate.new(cert)

            expect(sut.alternate_common_names).to include("example.com")
            expect(sut.alternate_common_names).to_not include("npboards.com")
            expect(sut.alternate_common_names).to_not include("www.npboards.com")
          end
        end
        context "when it has no subject alternate name extension" do
          it 'should expose no alternate names' do
            cert = OpenSSL::X509::Certificate.new VALID_CERT
            allow(cert).to receive(:extensions).and_return []
            sut = Certificate.new(cert)

            expect(sut.alternate_common_names).to eq([])
          end
        end
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
    describe "days from expiration" do
      it 'should know how many days until the certificate expires' do
        expires_at = Certificate.new(VALID_CERT).not_after
        clock = class_double(DateTime, :now => expires_at - 30.days)
        @sut = Certificate.new(VALID_CERT, clock)
        expect(@sut.expires_in?(30)).to be
      end
      context "when it's less than 1 day from expiring" do
        it 'should still know that it is expiring' do
          expires_at = Certificate.new(VALID_CERT).not_after
          clock = class_double(DateTime, :now => expires_at - 12.hours)
          @sut = Certificate.new(VALID_CERT, clock)
          expect(@sut.expires_in?(1)).to be
        end
      end
      context "when it's not expiring in the given timeframe" do
        it 'should not think its expiring within the given number of days' do
          expires_at = Certificate.new(VALID_CERT).not_after
          clock = class_double(DateTime, :now => expires_at - 60.days)
          @sut = Certificate.new(VALID_CERT, clock)
          expect(@sut.expires_in?(30)).to_not be
        end
      end
    end
  end
end
