module Thing::Contract
  class Create < Reform::Form
    property :name
    property :description
    property :file, virtual: true

    extend Paperdragon::Model::Writer
    processable_writer :image
    property :image_meta_data, deserializer: {writeable: false}

    validates :name, presence: true
    validates :description, length: {in: 4..160}, allow_blank: true
    validates :file, file_size: {less_than: 1.megabyte},
                     file_content_type: {allow: ['image/jpeg', 'image/png']}

    collection :users,
               populate_if_empty: :populate_if_empty_user!,
               prepopulator: :prepopulate_users!,
               skip_if: :all_blank do
      property :email
      property :remove, virtual: true

      validates :email, presence: true # email: true
      validate :authorship_limit_reached?

      def authorship_limit_reached?
        return if model.authorships.find_all { |au| au.confirmed.to_i.zero? }.size < 5

        errors.add('user', 'This user has too many unconfirmed authorships')
      end

      def removeable?
        # on Create it will be false but on Update user.persisted? might be true
        model.persisted?
      end
    end

    validates :users, length: {maximum: 3}

    private

    def prepopulate_users!(_options)
      (3 - users.size).times { users << User.new }
    end

    def populate_if_empty_user!(options)
      User.find_by_email(options[:fragment]['email']) or User.new
    end
  end
end
