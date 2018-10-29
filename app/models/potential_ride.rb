class PotentialRide < ApplicationRecord
  belongs_to :ride_zone
  belongs_to :ride_upload
  belongs_to :voter, class_name: 'User', foreign_key: :voter_id
  
  has_one :ride
  
  enum status: [ :pending, :failed, :converted ]
  
  validates :ride_zone, presence: true
  validates :ride_upload, presence: true
  validates :name, presence: true
  validates :pickup_at, presence: true
  validates :from_address, presence: true
  validates :from_city, presence: true
  validates :status, presence: true
  
  phony_normalize :phone_number, as: :phone_number_normalized, default_country_code: 'US'
  
  def fail_because(reason)
    self.notes = self.notes.nil? ? reason : [self.notes, reason].join('; ')
    self.failed!
    self.save
  end
  
  def populate_from_csv_row(row)
    row.each do |c|
      fieldname = c[0].downcase
      if fieldname == 'pickup_at'
        pickup = Chronic.parse(c[1])
        pickup = pickup.change(month: '11', day: '06')
        self.pickup_at = pickup.utc
      else
        val = c[1].present? ? c[1] : ''
        self.send "#{fieldname}=", val
      end
    end
    self
  end
end
