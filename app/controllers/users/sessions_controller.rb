class Users::SessionsController < Devise::SessionsController
  protected

  def self.controller_path
    "devise/sessions"
  end
end
