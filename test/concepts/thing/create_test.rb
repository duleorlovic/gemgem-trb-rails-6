require 'test_helper'

class ThingOperationCreateTest < ActiveSupport::TestCase
  test 'without params' do
    result = Thing::Operation::Create.(
      params: {
      },
    )
    refute result.success?
    assert result[:model].is_a? Thing
  end

  test 'persist' do
    result = Thing::Operation::Create.(
      params: {
        thing: {
          name: 'MyThing',
        },
      },
    )
    assert result.success?
    assert_equal 'MyThing', result[:model].name
  end

  test 'validation errors' do
    result = Thing::Operation::Create.(
      params: {
        thing: {
          description: 'a',
        },
      },
    )
    refute result.success?
    assert_equal 'can\'t be blank', result['result.contract.default'].errors.messages[:name].first
    assert_equal 'is too short (minimum is 4 characters)', result['result.contract.default'].errors.messages[:description].first
  end
end
