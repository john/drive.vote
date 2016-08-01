class Campaign < ApplicationRecord
  include HasPartyAffiliation
  
  belongs_to :election
  
  validates_presence_of :owner_id, :slug, :name
  validates_uniqueness_of :slug, :name
end
