module Thing::Contract
  class Update < Create
    feature Disposable::Twin::Persisted
    property :name, writeable: false

    collection :users, inherit: true, populator: :user! do
      property :remove, virtual: true
    end

    private

    def user!(fragment:, index:, **)
      if fragment['remove'] == '1'
        deserialized_user = users.find { |u| u.id.to_s == fragment['id'] }
        users.delete(deserialized_user)
        return skip!
      end

      return skip! if users[index] # skip if already existing

      users.insert(index, User.new)
    end
  end
end
