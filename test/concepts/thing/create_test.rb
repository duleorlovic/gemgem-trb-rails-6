require 'test_helper'

class ThingOperationCreateTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess # for fixture_file_upload

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

  test 'all emails blank' do
    result = Thing::Operation::Create.(
      params: {
        thing: {
          name: 'MyThing',
          users: [
            {email: ''},
          ]
        },
      },
    )
    assert result.success?
    assert_equal [], result[:model].users
  end

  test 'valid new and existing email' do
    existing = User.create(email: 'existing@trb.org') # TODO: replace with operation, once we got one.
    assert_equal 1, User.count

    result = Thing::Operation::Create.(
      params: {
        thing: {
          name: 'MyThing',
          # 'users_attributes' => {
          #   '0' => { 'email' => existing.email },
          #   '1' => { 'email' => 'new@trb.org' },
          # },
          users: [
            {'email' => existing.email},
            {'email' => 'new@trb.org'},
          ],
        },
      },
    )

    assert result.success?, result['contract.default'].errors.messages.to_s
    assert_equal 2, User.count
    assert_equal 2, result[:model].users.size

    result_existing = result[:model].users.first
    expected = {id: existing.id, email: existing.email}
    assert_equal expected, result_existing.slice(:id, :email).symbolize_keys
    refute Tyrant::Authenticatable.new(result_existing).confirmable?

    result_new = result[:model].users.second
    assert_equal 'new@trb.org', result_new.email
    assert Tyrant::Authenticatable.new(result_new).confirmable?
  end

  test 'number of users > 3' do
    emails = 4.times.collect { |i| {'email' => "#{i}@trb.org"} }
    result = Thing::Operation::Create.(
      params: {
        thing: {
          name: 'MyThing',
          users: emails,
        },
      },
    )

    refute result.success?
    assert_equal result['contract.default'].errors.messages.to_s, '{:users=>["is too long (maximum is 3 characters)"]}'
  end

  test 'authorship_limit_reached' do
    user = {'email' => 'nick@trb.org'}
    5.times { |i| Thing::Operation::Create.(params: {thing: {name: "Rails #{i}", users: [user]}}) }
    result = Thing::Operation::Create.(params: {thing: {name: 'Rails', users: [user]}})

    refute result.success?
    assert_equal result['contract.default'].errors.messages.to_s, '{:"users.user"=>["This user has too many unconfirmed authorships"]}'
  end

  test 'file upload' do
    result = Thing::Operation::Create.(
      params: {
        thing: {
          name: 'MyThing',
          file: fixture_file_upload('data/logo.png', 'image/png')
        },
      },
    )
    assert result.success?
    assert Paperdragon::Attachment.new(result[:model].image_meta_data).exists?
  end

  test 'invalid file format' do
    result = Thing::Operation::Create.(
      params: {
        thing: {
          name: 'MyThing',
          file: fixture_file_upload('data/text.txt')
        },
      },
    )
    refute result.success?
    assert_equal 'file should be one of image/jpeg, image/png', result['result.contract.default'].errors.messages[:file].first
  end
end
