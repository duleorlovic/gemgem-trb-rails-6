module Session::Contract
  class SignIn < Reform::Form
    property :email, virtual: true
    property :password, virtual: true

    validates :email, :password, presence: true
    validate :password_ok?

    attr_reader :user

    private

    def password_ok?
      return if email.blank? || password.blank?

      @user = User.find_by(email: email)

      return if @user && Tyrant::Authenticatable.new(@user).digest?(password)

      errors.add(:password, 'Wrong password')
    end
  end
end
