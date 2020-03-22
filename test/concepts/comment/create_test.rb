require 'test_helper'

class CommentOperationCreateTest < ActiveSupport::TestCase
  test 'persist' do
    thing = Thing::Operation::Create.(params: {thing: {name: 'Ruby'}})[:model]

    result = Comment::Operation::Create.(
      params: {
        comment: {
          body: 'Fantastic!',
          weight: '1',
          user: {
            email: 'jonny@trb.org',
          },
        },
        thing_id: thing.id,
      }
    )

    assert result.success?, result['contract.default'].errors.messages.to_s

    comment = result[:model]
    assert comment.persisted?
    assert_equal 'Ruby', comment.thing.name
    assert_equal 'Fantastic!', comment.body
    assert_equal 1, comment.weight

    user = comment.user
    assert user.persisted?
    assert_equal 'jonny@trb.org', user.email
  end

  test 'invalid because of presence' do
    result = Comment::Operation::Create.(params: {comment: {}})
    form = result['contract.default']

    refute result.success?
    errors = {
      body: ['is too short (minimum is 6 characters)'],
      weight: ['is not included in the list'],
      thing: ["can't be blank"],
      'user.email': ["can't be blank"]
    }
    assert_equal errors, form.errors.messages
  end

  test 'invalid because of body length and weight inclusion' do
    thing = Thing::Operation::Create.(params: {thing: {name: 'Ruby'}})[:model]

    result = Comment::Operation::Create.(
      params: {
        comment: {
          body: 'a' * 161,
          weight: 'a',
          user: {
            email: 'jonny@trb.org',
          },
        },
        thing_id: thing.id,
      }
    )
    form = result['contract.default']

    refute result.success?
    errors = {
      body: ['is too long (maximum is 160 characters)'],
      weight: ['is not included in the list'],
    }
    assert_equal errors, form.errors.messages
  end

  test 'use existing user find by email' do
    thing = Thing::Operation::Create.(params: {thing: {name: 'Ruby'}})[:model]

    result1 = Comment::Operation::Create.(params: {comment: {body: 'Fantastic!', weight: '1', 'user' => {'email' => 'jonny@trb.org',},}, thing_id: thing.id,})
    result2 = Comment::Operation::Create.(params: {comment: {body: 'Fantastic!', weight: '1', 'user' => {'email' => 'jonny@trb.org',},}, thing_id: thing.id,})

    assert result1.success?
    assert result2.success?
    assert_equal result1[:model].user.id, result2[:model].user.id
  end
end
