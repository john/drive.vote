require File.expand_path '../../end_to_end.rb', __FILE__

Feature "volunteering to drive" do
  def fill_in(name: "Hillary Clinton", email: "chief@hillaryclinton.com",
              phone: '555-333-4444', city_state: 'Orlando, FL', password: 'topsecret')
    name_field = b.text_field(name: "user[name]")
    email_field = b.text_field(name: "user[email]")
    phone_field = b.text_field(name: "user[phone_number]")
    city_state_field = b.text_field(name: "user[city_state]")
    password_field = b.text_field(name: "user[password]")

    name_field.set(name)
    email_field.set(email)
    phone_field.set(phone)
    city_state_field.set(city_state)
    password_field.set(password)
  end

  def submit
    b.element(:css, '#new_user .btn').click
  end

  Scenario "filling in " do
    First "visit volunteer page" do
      visit volunteer_to_drive_url
      assert_match /Volunteer to Drive!/, b.element(:css, 'h3').text
    end

    Then "fill in form with missing password" do
      fill_in(password: nil)
      submit
    end

    Check "we're still on the form page" do
      assert_equal current_url, volunteer_to_drive_url
    end


    Then "fill in form an invalid city state" do
      fill_in(city_state: "Juneau, AK")
      submit
      binding.pry
    end

    Check "invalid state error appeared" do
      assert_match /State isn't a supported state/, b.element(:id, 'error_explanation').text
    end

    Then "fill in form properly" do
      fill_in
      submit
    end
    Check "we're on the thank you page" do
      assert_equal '/confirm', current_path
      assert_equal 'Thanks!', b.element(:css, 'h1').text
    end
  end
end
