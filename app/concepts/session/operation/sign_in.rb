module Session::Operation
  class SignIn < Trailblazer::Operation
    step Model(User, :new)
    step Contract::Build(constant: Session::Contract::SignIn)
    step Contract::Validate(key: :user)
  end
end
