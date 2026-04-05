class Users::PasswordsController < Devise::PasswordsController
  protected

  def self.controller_path
    "devise/passwords"
  end
end
