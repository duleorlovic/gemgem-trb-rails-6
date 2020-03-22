module Session::Contract
  class WakeUp < Reform::Form
    property :password, virtual: true
    property :confirm_password, virtual: true

    validates :password, :confirm_password, presence: true
    validate :password_ok?

    def password_ok?
      return unless password && confirm_password
      return if password == confirm_password

      errors.add(:password, "Passwords don't match")
    end
  end
end
