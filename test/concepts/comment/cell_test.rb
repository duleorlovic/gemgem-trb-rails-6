require 'test_helper'

class CommentCellTest < Cell::TestCase
  controller ThingsController

  test 'show' do
    thing = Thing::Operation::Create.(params: {thing: {name: 'Rails'}})[:model]
    result = Comment::Operation::Create.(params: {comment: {body: 'Excellent', weight: '0', user: {email: 'zavan@trb.org'}}, thing_id: thing.id})
    assert result.success?
    result = Comment::Operation::Create.(params: {comment: {body: '!Well.', weight: '1', user: {email: 'jonny@trb.org'}}, thing_id: thing.id})
    assert result.success?
    result = Comment::Operation::Create.(params: {comment: {body: 'Cool stuff!', weight: '0', user: {email: 'chris@trb.org'}}, thing_id: thing.id})
    assert result.success?
    result = Comment::Operation::Create.(params: {comment: {body: 'Improving.', weight: '1', user: {email: 'hilz@trb.org'}}, thing_id: thing.id})
    assert result.success?

    html = concept('comment/cell/grid', thing).to_s

    comments = html.all(:css, '.comment')
    assert_equal 3, comments.size

    first = comments[0]
    assert first.find('.header').has_content? 'hilz@trb.org'
    assert first.find('.header time')['datetime'].match? /\d\d-/
    assert first.has_content? 'Improving'
    refute first.has_selector? '.fi-heart'
    refute first[:class].match? /\send/

    second = comments[1]
    assert second.find('.header').has_content? 'chris@trb.org'
    assert second.find('.header time')['datetime'].match? /\d\d-/
    assert second.has_content? 'Cool stuff!'
    assert second.has_selector?  '.fi-heart'
    refute second[:class].match? /\send/

    third = comments[2]
    assert third.find('.header').has_content? 'jonny@trb.org'
    assert third.find('.header time')['datetime'].match? /\d\d-/
    assert third.has_content? '!Well.'
    refute third.has_selector? '.fi-heart'
    assert third[:class].match? /\send/ # last grid item.

    # 'More!'
    assert_equal "/things/#{thing.id}/next_comments?page=2", html.find('#next a')['href']
  end

  test 'append page 2' do
    thing = Thing::Operation::Create.(params: {thing: {name: 'Rails'}})[:model]
    result = Comment::Operation::Create.(params: {comment: {body: 'Excellent', weight: '0', user: {email: 'zavan@trb.org'}}, thing_id: thing.id})
    assert result.success?
    result = Comment::Operation::Create.(params: {comment: {body: '!Well.', weight: '1', user: {email: 'jonny@trb.org'}}, thing_id: thing.id})
    assert result.success?
    result = Comment::Operation::Create.(params: {comment: {body: 'Cool stuff!', weight: '0', user: {email: 'chris@trb.org'}}, thing_id: thing.id})
    assert result.success?
    result = Comment::Operation::Create.(params: {comment: {body: 'Improving.', weight: '1', user: {email: 'hilz@trb.org'}}, thing_id: thing.id})
    assert result.success?

    html = concept('comment/cell/grid', thing, page: 2).(:append)

    assert_match /outerHTML/, html.to_s
    assert_match /zavan@trb.org/, html.to_s
  end
end
