class RideZonePdf < Prawn::Document

  def initialize(ride_zone, view)
    super()
    #@ride_zone = ride_zone
    #@view = view

    logo
    sentence1
    phone_number(ride_zone)
    sentence2
    url(ride_zone)
  end

  def logo
    image "#{Rails.root}/app/assets/images/dtv-logo-260w-eng.png", width: 260, height: 136
  end

  def sentence1
    text "\n\nFor a free ride to or from your polling\nplace on Nov. 8, send a text to\n\n", size: 15
  end

  def phone_number(ride_zone)
    move_up 10
    text  "#{ride_zone.phone_number.phony_formatted(normalize: :US, spaces: '-')}\n\n", size: 25, style: :bold
  end

  def sentence2
    text "Or to schedule a ride in advance go to\n\n", size: 15
  end

  def url(ride_zone)
    move_up 10
    text "<link href='https://drive.vote'>www.drive.vote/get_a_ride/#{ride_zone.slug}</link>", inline_format: true, size: 20, style: :bold
  end
end