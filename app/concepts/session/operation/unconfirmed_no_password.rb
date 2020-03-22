module Session::Operation
  class UnconfirmedNoPassword < Trailblazer::Operation
    step :mark_user_as_confirmable

    def mark_user_as_confirmable(ctx, **)
      auth = Tyrant::Authenticatable.new(ctx[:params][:user])
      auth.confirmable!
      auth.sync
    end
  end
end
