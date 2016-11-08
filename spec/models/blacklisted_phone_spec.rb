require 'rails_helper'

RSpec.describe BlacklistedPhone, type: :model do
  describe '#has_voter_phone?' do

    let(:convo) { create :conversation_with_messages }

    context 'voter phone is blacklisted' do
      it 'returns true' do
        convo.blacklist_voter_phone

        expect(BlacklistedPhone.has_voter_phone?(convo.from_phone)).to be_truthy
      end
    end

    context 'voter phone is not blacklisted' do
      it 'returns false' do
        expect(BlacklistedPhone.has_voter_phone?(convo.from_phone)).to be_falsey
      end
    end
  end
end
