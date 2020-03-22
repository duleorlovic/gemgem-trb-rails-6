module Thing::Operation
  class Update < Trailblazer::Operation
    step Model(Thing, :find_by)
    step Contract::Build(constant: Thing::Contract::Update)
    step Contract::Validate(key: :thing)
    step Contract::Persist()
    step :clear_cache!

    private

    def clear_cache!(_ctx, **)
      CacheVersion.for('thing/cell/grid').expire!
    end
  end
end
