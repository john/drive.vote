require File.expand_path '../../end_to_end.rb', __FILE__

Feature "static pages" do
  Scenario "browsing around" do
    First "visit the home page" do
      visit root_url
      assert_match /Drive the Vote/, b.element(:css, '.description').text
    end

    Then "visita la página de inicio" do
      visit '/?locale=es'
      assert_match /Conduzca el voto/, b.element(:css, '.description').text
    end

    Then "visit the about page" do
      visit '/about'
      assert_match /What is this?/, b.element(:css, 'h4').text
    end

    Then "visit the terms of service" do
      visit '/terms_of_service'
      assert_match /Terms of Service/, b.element(:css, 'h1').text
    end
  end
end
