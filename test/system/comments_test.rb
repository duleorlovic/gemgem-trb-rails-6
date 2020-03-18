require 'application_system_test_case'

class CommentsTest < ApplicationSystemTestCase
  test 'create comment' do
    thing = Thing::Operation::Create.(params: { thing: { name: 'Rails' } })[:model]
    visit "/things/#{thing.id}"

    fill_in 'Your comment', with: 'invalid'
    click_on 'Create Comment'

    assert_selector '#alert', text: 'Error'
    choose 'Nice!'
    fill_in 'Your Email', with: 'new@trb.to'
    click_button 'Create Comment'

    assert_selector '#notice', text: 'Created comment for "Rails"'
    assert_equal "/things/#{thing.id}", page.current_path
  end

  test '#next_comments' do
    thing = Thing::Operation::Create.(params: { thing: { name: 'First' } })[:model]
    4.times do |i|
      Comment::Operation::Create.(params: { comment: { body: "body-#{i}", weight: '0', user: { email: 'email@trb.org' } }, thing_id: thing.id })
    end
    visit thing_path(thing.id)

    refute_selector 'div', text: 'body-3'
    click_link 'More'
    assert_selector 'div', text: 'body-3'
  end
end
