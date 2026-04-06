require "test_helper"

class Users::RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "registration saves referred_by from session" do
    referrer = users(:one)

    # Visit shared page with ref param to store in session
    meal = meal_suggestions(:one)
    get shared_meal_path(meal, ref: referrer.id)

    # Register a new user in the same session
    post user_registration_path, params: {
      user: {
        email: "newuser@example.com",
        password: "password123",
        password_confirmation: "password123"
      }
    }

    new_user = User.find_by(email: "newuser@example.com")
    assert_not_nil new_user
    assert_equal referrer.id.to_s, new_user.referred_by
  end

  test "registration without ref session has nil referred_by" do
    post user_registration_path, params: {
      user: {
        email: "newuser2@example.com",
        password: "password123",
        password_confirmation: "password123"
      }
    }

    new_user = User.find_by(email: "newuser2@example.com")
    assert_not_nil new_user
    assert_nil new_user.referred_by
  end
end
