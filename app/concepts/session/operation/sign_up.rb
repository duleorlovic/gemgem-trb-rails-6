module Session::Operation
  class SignUp < Trailblazer::Operation
    step Model(User, :new)
    step Contract::Build(constant: Session::Contract::SignUp)
    step Contract::Validate(key: :user)
    step :authenticate
    step Contract::Persist()

    def authenticate(ctx, **)
      auth = Tyrant::Authenticatable.new(ctx[:model])
      auth.digest!(ctx['contract.default'].password)
      auth.confirmed!
      auth.sync
    end
  end
end
