module Comment::Operation
  class Create < Trailblazer::Operation
    step Model(Comment, :new)
    step :populate_associations
    step Contract::Build(constant: Comment::Contract::Create)
    step Contract::Validate(key: :comment)
    step Contract::Persist()

    def populate_associations(ctx, params:, **)
      ctx[:model].thing = Thing.find_by_id(params[:thing_id])
      ctx[:model].build_user
    end
  end
end
