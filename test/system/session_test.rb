require 'application_system_test_case'

class SessionsTest < ApplicationSystemTestCase
  def submit_sign_up!(email, password, confirm)
    within('form#new_user') do
      fill_in 'Email',    with: email
      fill_in 'Password', with: password
      fill_in 'Password, again', with: confirm
    end
    click_button 'Sign up!'
  end

  def submit_sign_in!(email, password)
    within('form#new_session') do
      fill_in 'Email',    with: email
      fill_in 'Password', with: password
    end
    click_button 'Sign in'
  end

  test 'sign up and sign out' do
    visit 'sessions/sign_up_form'
    submit_sign_up!('', '', '')
    assert_text /can't be blank/
    submit_sign_up!('Scharrels@trb.org', '123', '321')
    assert_text /Passwords don't match/
    submit_sign_up!('Scharrels@trb.org', '123', '123')

    submit_sign_in!('Scharrels@trb.org', '123')
    assert_selector 'li', text: 'Hi, Scharrels@trb.org'

    visit 'sessions/sign_out'
    assert_equal '/', page.current_path
    assert_selector 'li', text: 'Hi, Scharrels@trb.org', count: 0
  end

  test 'wake up' do
    user = Thing::Operation::Create.(params: {thing: {name: 'Taz', users: [{'email' => 'fred@taz.de'}]}})[:model].users[0]

    token = Tyrant::Authenticatable.new(user).confirmation_token

    visit "sessions/wake_up_form/#{user.id}/?confirmation_token=#{token}"

    assert_text /account, fred@taz.de!/

    fill_in 'Password', with: '123'
    click_button('Engage')
    assert_text "Passwords don't match" # flash.

    fill_in 'Password',        with: '123'
    fill_in 'Password, again', with: '123'
    click_button('Engage')

    assert_text 'Password changed' # flash.
    user.reload
    assert Tyrant::Authenticatable.new(user).confirmed?

    assert_equal '/sessions/sign_in_form', page.current_path

    # sign in.
    fill_in 'Email', with: 'fred@taz.de'
    fill_in 'Password', with: '123'
    click_button 'Sign in'

    assert_selector 'li', text: 'Hi, fred@taz.de'
  end
end
