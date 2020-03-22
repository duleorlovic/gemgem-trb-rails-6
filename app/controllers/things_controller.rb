class ThingsController < ApplicationController
  def index; end

  def show
    thing_operation = run Thing::Operation::Update
    @thing = thing_operation[:model]

    run Comment::Operation::Create # overrides @model and @form
  end

  def create_comment
    thing_operation = run Thing::Operation::Update
    @thing = thing_operation[:model]

    run Comment::Operation::Create, params: params.merge(thing_id: params[:id]) do
      flash[:notice] = "Created comment for \"#{@thing.name}\""
      return redirect_to thing_path(@thing)
    end

    flash.now[:alert] = 'Error'
    render :show
  end

  def next_comments
    run Thing::Operation::Update

    render js: concept('/comment/cell/grid', @model, page: params[:page]).(:append)
  end

  def new
    run Thing::Operation::Create
    @form.prepopulate!
  end

  def create
    run Thing::Operation::Create do |result|
      flash[:notice] = 'Successfully created'
      return redirect_to thing_path(result[:model])
    end

    flash.now[:alert] = 'Error'
    render action: :new
  end

  def edit
    run Thing::Operation::Update
    @form.prepopulate!
    render action: :new
  end

  def update
    run Thing::Operation::Update do |result|
      flash[:notice] = 'Successfully updated'
      return redirect_to thing_path(result[:model])
    end

    flash.now[:alert] = 'Error'
    render action: :new
  end
end
