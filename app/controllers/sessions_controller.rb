class SessionsController < ApplicationController
  # before_filter should be used when op not involved at all.
  before_action only: %i[sign_in_form sign_up_form] do
    redirect_to root_path if tyrant.signed_in?
  end

  def sign_up_form
    run Session::Operation::SignUp
  end

  def sign_up
    run Session::Operation::SignUp do |_result|
      flash[:notice] = 'Please log in now!'
      return redirect_to sessions_sign_in_form_path
    end

    flash.now[:alert] = @form.errors.messages
    render action: :sign_up_form
  end

  def sign_in_form
    run Session::Operation::SignIn
  end

  def sign_in
    run Session::Operation::SignIn do |result|
      flash[:notice] = 'Successfully signed in'
      tyrant.sign_in! result['contract.default'].user
      return redirect_to root_path
    end

    flash.now[:alert] = @form.errors.messages
    render action: :sign_in_form
  end

  def wake_up_form
    run Session::Operation::WakeUp::Form do
      return # continue rendering form is token is valid
    end

    flash[:alert] = result[:error_message]
    redirect_to root_path
  end

  def wake_up
    run Session::Operation::WakeUp do
      flash[:notice] = 'Password changed'
      return redirect_to sessions_sign_in_form_path
    end

    render :wake_up_form
  end

  def sign_out
    run Session::Operation::SignOut do
      tyrant.sign_out!
      redirect_to root_path
    end
  end
end
