module Session::Operation
  class WakeUp < Trailblazer::Operation
    step Model(User, :find)
    step Contract::Build(constant: Session::Contract::WakeUp)
    step Contract::Validate(key: :user)
    step :wake_up!
    step Contract::Persist()

    def wake_up!(ctx, **)
      contract = ctx['contract.default']
      auth = Tyrant::Authenticatable.new(contract.model)
      auth.digest!(contract.password)
      auth.confirmed!
      auth.sync
    end

    class Form < Trailblazer::Operation
      step Model(User, :find)
      step :confirmation_token_is_valid?
      step Contract::Build(constant: Session::Contract::WakeUp)

      def confirmation_token_is_valid?(ctx, params:, **)
        return true if Tyrant::Authenticatable.new(ctx[:model]).confirmable?(params[:confirmation_token])

        ctx[:error_message] = 'Invalid token'
        false
      end
    end
  end
end
