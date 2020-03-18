module Comment::Contract
  class Create < Reform::Form
    def self.weights
      { '0' => 'Nice!', '1' => 'Rubbish!' }
    end

    def weights
      [self.class.weights.to_a, :first, :last]
    end

    property :body
    property :weight, prepopulator: -> { self.weight = '0' }
    property :thing

    validates :body, length: { in: 6..160 }
    validates :weight, inclusion: { in: weights.keys }
    validates :thing, :user, presence: true

    property :user do
      # prepopulator: ->(*) { self.user = User.new },
      # populate_if_empty: lambda { |*| User.new } do
      property :email
      validates :email, presence: true # email: true
    end
  end
end
