class Election < ApplicationRecord
  has_many :campaigns
  
  validates_presence_of :owner_id, :slug, :name
  validates_uniqueness_of :slug, :name
  
end
