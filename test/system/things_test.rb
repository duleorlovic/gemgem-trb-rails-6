require 'application_system_test_case'

class ThingsTest < ApplicationSystemTestCase
  test 'allow anonymous' do
    visit new_thing_path
    click_on 'Create Thing'
    assert_selector '#alert', text: 'Error'

    fill_in 'Name', with: 'My Name'
    click_on 'Create Thing'
    assert_selector '#notice', text: 'Successfully created'

    thing = Thing.find_by(name: 'My Name')
    visit edit_thing_path(thing)
    assert_selector '#thing_name[readonly="readonly"][value="My Name"]'
    fill_in 'Description', with: 'My Desc'
    click_on 'Update Thing'
    assert_selector '#notice', text: 'Successfully updated'
    assert_match /My Desc/, page.body
  end
end
