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

  test 'cell' do
    Thing.delete_all
    Thing::Operation::Create.(params: {thing: {name: 'First'}})
    Thing::Operation::Create.(params: {thing: {name: 'Last'}})
    visit things_path
    assert_selector '.columns', text: 'Last'
    assert_selector '.columns.end', text: 'First'
  end
end
