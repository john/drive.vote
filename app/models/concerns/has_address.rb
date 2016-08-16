module HasAddress
  extend ActiveSupport::Concern

  UNKNOWN_ADDRESS = 'Unknown'.freeze

  def has_unknown_destination?
    self.to_address == UNKNOWN_ADDRESS
  end

end