class RideUpload < ApplicationRecord
  ALLOWED_MIME_TYPES = ['text/csv']
  
  before_validation :compute_csv_hash
  
  has_one_attached :csv
  
  belongs_to :user
  belongs_to :ride_zone
  has_many :potential_rides, -> { order 'id ASC' }
  
  enum status: [ :pending, :queued, :complete, :complete_with_failures, :failed ]
  
  validates :user, presence: true
  validates :ride_zone, presence: true
  validates :csv, presence: true
  validates :status, presence: true
  validates :name, uniqueness: true
  validates_uniqueness_of :csv_hash, on: :create, allow_blank: true, message: ': This file has already been uploaded.'
  validate :csv_must_be_correct_content_type
  
  def failed_potential_rides
    PotentialRide.where(ride_upload: self, status: :failed)
  end
  
  # TODO: more validations:
  # validate :has_correct_columns
  
  private
  
  def compute_csv_hash
    self.csv_hash = Digest::MD5.hexdigest(self.csv.download) if self.csv.attached?
  end
  
  def csv_must_be_correct_content_type
    if csv.attached? && !csv.blob.content_type.in?(ALLOWED_MIME_TYPES)
      errors.add(:csv, "Must be a CSV file")
    end
  end
  
end
