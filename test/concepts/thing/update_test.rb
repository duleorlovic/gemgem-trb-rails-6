require 'test_helper'

class ThingOperationUpdateTest < ActiveSupport::TestCase
  test 'rendering three' do # DISCUSS: not sure if that will stay here, but I like the idea of presentation/logic in one place.
    thing = Thing::Operation::Create.(params: {thing: {name: 'Rails', description: 'Kickass web dev', 'users' => [{'email' => 'solnic@trb.org'}]}})[:model]
    form = Thing::Operation::Update.(params: {id: thing.id})['contract.default']
    form.prepopulate! # this is a bit of an API breach.

    assert_equal 3, form.users.size # always offer 3 user emails.
    assert_equal 'solnic@trb.org', form.users.first.email
    assert_nil form.users.second.email
    assert_nil form.users.third.email
  end

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

  test 'valid, new and existing email' do
    thing = Thing::Operation::Create.(params: {thing: {name: 'Rails', description: 'Kickass web dev', 'users' => [{'email' => 'solnic@trb.org'}]}})[:model]
    solnic = thing.users[0]
    model  = Thing::Operation::Update.(
      params: {
        id: thing.id,
        thing: {
          'users' => [
            {'id' => solnic.id, 'email' => 'solnicXXXX@trb.org'},
            {'email' => 'nick@trb.org'},
          ],
        },
      },
    )[:model]

    assert_equal 2, model.users.size
    assert_equal({'id' => solnic.id, 'email' => 'solnic@trb.org'}, model.users[0].attributes.slice('id', 'email')) # existing user, nothing changed.
    assert_equal 'nick@trb.org', model.users[1].email # new user created.
    assert model.users[1].persisted?
  end

  # try to change emails.
  test 'doesn\'t allow changing existing email' do
    thing = Thing::Operation::Create.(params: {thing: {name: 'Rails', 'users' => [{'email' => 'nick@trb.org'}]}})[:model]

    updated = Thing::Operation::Update.(params: {id: thing.id, thing: {'users' => [{'email' => 'wrong@trb.org'}]}})[:model]
    assert_equal 'nick@trb.org', updated.users[0].email
  end

  test 'all emails blank' do
    thing = Thing::Operation::Create.(params: {thing: {name: 'Rails', 'users' => []}})[:model]

    result = Thing::Operation::Update.(params: {id: thing.id, thing: {'users' => [{'email' => ''}, {'email' => ''}, {'email' => ''}]}})

    assert result
    assert_equal [], result[:model].users
  end

  test 'allows removing' do
    thing = Thing::Operation::Create.(params: {thing: {name: 'Rails', 'users' => [{'email' => 'joe@trb.org'}]}})[:model]
    joe = thing.users[0]

    result = Thing::Operation::Update.(params: {id: thing.id, thing: {'users' => [{'email' => ''}, {'id' => joe.id.to_s, 'remove' => '1'}]}})

    assert result
    assert_equal [], result[:model].users
    assert joe.persisted?
  end

  # TODO: This test will fail on current code, improve Updatee populator user!
  # test 'remove and add in same request' do
  #   thing = Thing::Operation::Create.(params: { thing: { name: 'Rails', description: 'Kickass web dev', 'users' => [{ 'email' => 'solnic@trb.org' }] } })[:model]
  #   solnic = thing.users[0]
  #   model  = Thing::Operation::Update.(
  #     params: {
  #       id: thing.id,
  #       thing: {
  #         'users' => [
  #           { 'id' => solnic.id, 'remove' => '1' },
  #           { 'email' => 'nick@trb.org' },
  #         ],
  #       },
  #     },
  #   )[:model]

  #   assert_equal 1, model.users.size
  #   assert_equal 'nick@trb.org', model.users[0].email # new user created.
  #   refute_equal solnic.id, model.users[0].id
  # end
end
