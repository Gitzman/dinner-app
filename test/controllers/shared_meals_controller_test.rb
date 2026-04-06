require "test_helper"

class SharedMealsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @meal = meal_suggestions(:one)
    @user = users(:one)
  end

  test "show renders recipe without authentication" do
    get shared_meal_path(@meal)
    assert_response :success
    assert_select "h2", "Spaghetti Carbonara"
  end

  test "show displays sign-up CTA for unauthenticated users" do
    get shared_meal_path(@meal)
    assert_response :success
    assert_select "a[href=?]", new_user_registration_path, minimum: 1
  end

  test "show hides sign-up CTA for authenticated users" do
    sign_in @user
    get shared_meal_path(@meal)
    assert_response :success
    assert_no_match(/Sign Up Free/, response.body)
  end

  test "show stores ref param in session" do
    get shared_meal_path(@meal, ref: "friend123")
    assert_response :success
    assert_equal "friend123", session[:ref]
  end

  test "show renders favorite button as sign-up link for guests" do
    get shared_meal_path(@meal)
    assert_response :success
    assert_select "a[title='Sign up to save this recipe']"
  end

  test "show renders interactive favorite button for signed-in users" do
    sign_in @user
    get shared_meal_path(@meal)
    assert_response :success
    assert_select "button[data-controller='favorite']"
  end

  test "show returns 404 for nonexistent meal" do
    get shared_meal_path(id: 999999)
    assert_response :not_found
  end
end
