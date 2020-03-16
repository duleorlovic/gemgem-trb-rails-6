require 'test_helper'

class ThingOperationCreateTest < ActiveSupport::TestCase
  test 'persist valid, ignores name' do
    result = Thing::Operation::Create.(params: {thing: {name: 'Rails', description: 'Kickass web dev'}})
    thing = result[:model]

    Thing::Operation::Update.(
      params: {
        id: thing.id,
        thing: {name: 'Lotus', description: 'MVC, well..'},
      },
    )

    thing.reload
    assert_equal thing.name, 'Rails'
    assert_equal thing.description, 'MVC, well..'
  end
end
