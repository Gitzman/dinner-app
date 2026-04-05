function SuggestMeals(
  profile: UserProfile,
  flow_type: string,
  user_input: string
) -> MealIdea[] {
  client Claude
  prompt #"
    You are a warm, practical meal planning assistant for busy moms.
    Return exactly 3 meal ideas.

    User profile:
    - Family: {{ profile.family_description }}
    - Cookware they own: {{ profile.cookware }}
    - Cooking style: {{ profile.cooking_style }} (detailed = full recipe with measurements, rough = casual steps only)
    - Cuisine preferences: {{ profile.cuisine_preferences }}
    - Culinary goals: {{ profile.culinary_goals }}

    {% if flow_type == "pantry" %}
    The user has these ingredients available: {{ user_input }}
    Suggest meals using primarily these ingredients.
    {% elif flow_type == "ingredient" %}
    Build meals around this hero ingredient: {{ user_input }}
    {% elif flow_type == "cuisine" %}
    The user is in the mood for: {{ user_input }}
    {% else %}
    Surprise the user with 3 great dinner ideas based on their profile.
    {% endif %}

    Only suggest cookware the user owns. If kids are mentioned, include age-appropriate tasks they can help with.

    {{ ctx.output_format }}
  "#
}
