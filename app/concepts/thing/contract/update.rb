module Thing::Contract
  class Update < Create
    property :name, writeable: false
  end
end
