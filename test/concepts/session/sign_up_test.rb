require 'test_helper'

class SessionSignUpTest < ActiveSupport::TestCase
  test 'valid signup' do
    result = Session::Operation::SignUp.(
      params: {
        user: {
          email: 'selectport@trb.org',
          password: '123123',
          confirm_password: '123123',
        }
      }
    )

    assert result.success?
    assert result[:model].persisted?
    assert Tyrant::Authenticatable.new(result[:model]).digest?('123123')
  end

  test 'not filled' do
    result = Session::Operation::SignUp.(
      params: {
        user: {
          email: '',
          password: '',
          confirm_password: '',
        }
      }
    )

    refute result.success?
    assert_equal({email: ['can\'t be blank'], password: ['can\'t be blank'], confirm_password: ['can\'t be blank']}, result['contract.default'].errors.to_hash)
  end

  test 'password do not match' do
    result = Session::Operation::SignUp.(
      params: {
        user: {
          email: 'selectport@trb.org',
          password: '123123',
          confirm_password: 'wrong because drunk',
        }
      }
    )

    refute result.success?
    refute result[:model].persisted?
    assert_equal "{:password=>[\"Passwords don't match\"]}", result['contract.default'].errors.to_s
  end
end
