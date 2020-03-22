module Session::Contract
  class SignUp < Reform::Form
    property :email
    property :password, virtual: true
    property :confirm_password, virtual: true

    validates :email, :password, :confirm_password, presence: true
    validate :password_ok?

    def password_ok?
      return unless email && password
      return if password == confirm_password

      errors.add(:password, "Passwords don't match")
    end
  end
end
