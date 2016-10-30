module SignInHelpers
  def sign_in(email, password, remember: false)
    b.text_field(id: 'email').when_present.set email
    b.text_field(id: 'password').set password
    if remember
      b.checkbox(name: 'remember_me').set
    else
      b.checkbox(name: 'remember_me').clear
    end
    b.button(type: 'submit').click
  end

  def sign_in_user(user, remember: false)
    sign_in(user.email, user.password, remember)
  end

  def sign_out
    visit '/sign_out'
  end

  def sign_in_as_test_coach
    sign_in('teamtest-coach@z.fitfor90.com', 'StagePass')
  end
end
