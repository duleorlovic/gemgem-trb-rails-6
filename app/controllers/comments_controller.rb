class CommentsController < ApplicationController
  def new
    @thing = Thing.find(params[:thing_id]) # UI-specific logic!

    run Comment::Operation::Create
    # @form.prepopulate!
  end

  def create
    run Comment::Operation::Create do |ctx|
      flash[:notice] = "Created comment for \"#{ctx[:model].thing.name}\""

      return redirect_to thing_path(ctx[:model].thing)
    end

    @thing = Thing.find(params[:thing_id]) # UI-specific logic!
    render :new
  end
end
