class Users::RegistrationsController < Devise::RegistrationsController
  protected

  def self.controller_path
    "devise/registrations"
  end
end
