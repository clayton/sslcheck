require 'spec_helper'

module SSLCheck
  describe Client::Response do
    it 'should alias ca_bundle to peer_cert_chain' do
      response = Client::Response.new
      response.raw_peer_cert_chain = [CA_PARENT, CA_GRAND_PARENT]
      expect(response.ca_bundle).to be
      expect(response.ca_bundle.first.to_s).to eq(Certificate.new(CA_PARENT).to_s)
      expect(response.ca_bundle.last.to_s).to eq(Certificate.new(CA_GRAND_PARENT).to_s)
    end
  end
end
