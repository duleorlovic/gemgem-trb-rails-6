module Thing::Operation
  class Create < Trailblazer::Operation
    step Model(Thing, :new)
    step Contract::Build(constant: Thing::Contract::Create)
    step Contract::Validate(key: :thing)
    step Contract::Persist()
  end
end
