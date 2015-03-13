require 'spec_helper'

module SSLCheck
  describe Client::Response do
    it 'should alias ca_bundle to peer_cert_chain' do
      response = Client::Response.new
      response.peer_cert_chain = [1,2,3]
      expect(response.ca_bundle).to eq([1,2,3])
    end
  end
end
