class Election < ApplicationRecord
  has_many :campaigns
  validates_presence_of :slug, :name
  validates_uniqueness_of :slug, :name
  
end
