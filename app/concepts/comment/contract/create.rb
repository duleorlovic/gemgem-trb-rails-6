module Comment::Contract
  class Create < Reform::Form
    def self.weights
      {'0' => 'Nice!', '1' => 'Rubbish!'}
    end

    def weights
      [self.class.weights.to_a, :first, :last]
    end

    property :body
    property :weight, prepopulator: -> { self.weight = '0' }
    property :thing

    validates :body, length: {in: 6..160}
    validates :weight, inclusion: {in: weights.keys}
    validates :thing, :user, presence: true

    property :user,
             prepopulator: ->(*) { self.user = User.new },
             populator: :populate_user! do
      property :email
      validates :email, presence: true # email: true
    end

    def populate_user!(fragment:, **)
      self.user = User.find_by(email: fragment['email']) || User.new
    end
  end
end
