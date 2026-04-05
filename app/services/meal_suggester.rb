require_relative "../../baml_client/client"

class MealSuggester
  def self.call(user, flow_type:, user_input: "")
    profile = user.profile
    baml_profile = Baml::Types::UserProfile.new(
      family_description: profile.family_description.to_s,
      cookware: profile.cookware.to_s.split(",").map(&:strip),
      cooking_style: profile.cooking_style.to_s,
      cuisine_preferences: profile.cuisine_preferences.to_s.split(",").map(&:strip),
      culinary_goals: profile.culinary_goals.to_s
    )
    Baml.Client.SuggestMeals(
      profile: baml_profile,
      flow_type: flow_type,
      user_input: user_input
    )
  end
end
