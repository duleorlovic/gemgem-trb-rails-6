module Comment::Operation
  class Create < Trailblazer::Operation
    step Model(Comment, :new)
    step :populate_associations
    step Contract::Build(constant: Comment::Contract::Create)
    step Contract::Validate(key: :comment)
    step Contract::Persist()
    step :sign_up_sleeping!

    def populate_associations(ctx, params:, **)
      ctx[:model].thing = Thing.find_by_id(params[:thing_id])
      # we will use populators
      ctx[:model].build_user
    end

    def sign_up_sleeping!(ctx, **)
      Session::Operation::UnconfirmedNoPassword.(params: {user: ctx['contract.default'].user.model})
    end
  end
end
