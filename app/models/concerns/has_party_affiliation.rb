module HasPartyAffiliation
  extend ActiveSupport::Concern
  included do
    enum party_affiliation: [:democratic, :republican, :green, :libertarian, :conservative]
  end
end