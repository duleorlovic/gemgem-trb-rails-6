class ThingsController < ApplicationController
  def index; end

  def new
    run Thing::Operation::Create
  end

  def create
    run Thing::Operation::Create do |_result|
      flash[:notice] = 'Successfully created'
      return redirect_to things_path
    end

    flash.now[:alert] = 'Error'
    render action: :new
  end

  def edit
    run Thing::Operation::Update
    render action: :new
  end

  def update
    run Thing::Operation::Update do |_result|
      flash[:notice] = 'Successfully updated'
      return redirect_to things_path
    end

    flash.now[:alert] = 'Error'
    render action: :new
  end
end
