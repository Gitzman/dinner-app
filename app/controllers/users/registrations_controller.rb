class Users::RegistrationsController < Devise::RegistrationsController
  def create
    super do |user|
      if user.persisted? && session[:ref].present?
        user.update_column(:referred_by, session.delete(:ref))
      end
    end
  end

  protected

  def self.controller_path
    "devise/registrations"
  end
end
