module Thing::Operation
  class Create < Trailblazer::Operation
    step Model(Thing, :new)
    step Contract::Build(constant: Thing::Contract::Create)
    step Contract::Validate(key: :thing)
    step :upload_image!
    step :sign_up_sleeping! # before persist so we can check if user is new
    step Contract::Persist()
    step :clear_cache!

    private

    def upload_image!(ctx, **)
      contract = ctx['contract.default']
      return true unless contract.changed?(:file)

      contract.image!(contract.file) do |v|
        v.process!(:original)
        v.process!(:thumb) { |job| job.thumb!('120x120#') }
      end
    end

    def clear_cache!(_ctx, **)
      CacheVersion.for('thing/cell/grid').expire!
    end

    def sign_up_sleeping!(ctx, **)
      ctx['contract.default'].users.each do |user|
        next if user.persisted?

        Session::Operation::UnconfirmedNoPassword.(params: {user: user.model})
      end
    end
  end
end
