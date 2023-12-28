document.addEventListener("DOMContentLoaded", function() {
  debugger
  function generateChannelId() {
    const timestamp = new Date().getTime();
    const random = Math.floor(Math.random() * 1000000);
    return `${timestamp}-${random}`;
  }

  const channel_id = generateChannelId(); 

  // Subscribe to the WebSocket channel
  const channel = App.cable.subscriptions.create(
    { channel: "RecipesChannel", id: channel_id },
    {
      connected() {},
      disconnected() {},
      received(data) {
        // Handle data received from the server, e.g., update recipe list
        updateRecipeList(data.recipes);
      },
    }
  );

  // Slider initialization
  // const ratingSlider = document.getElementById("rating-slider");
  // const ratingTooltip = document.getElementById("rating-tooltip");
  const resetFiltersButton = document.getElementById("reset-filters");

  // noUiSlider.create(ratingSlider, {
  //   start: [0],
  //   range: { min: 0, max: 5 },
  //   step: 0.1,
  //   tooltips: [wNumb({ decimals: 1 })],
  // });

  // ratingSlider.noUiSlider.on("update", function(values, handle) {
  //   ratingTooltip.innerText = values[handle];
  // });

  // ratingSlider.noUiSlider.on("change", function(values, handle) {
  //   const selectedRating = parseFloat(values[handle]);
  //   channel.perform("filter_by_rating", { rating: selectedRating });
  // });

  // Ingredient filters
  const ingredientButtons = document.querySelectorAll(".ingredient-filter");

  ingredientButtons.forEach(button => {
    button.addEventListener("click", function() {
      const selectedIngredient = this.getAttribute("data-ingredient");
      debugger
      channel.perform("filter_by_ingredient", { ingredient: selectedIngredient });
    });
  });

  // Reset Filters
  resetFiltersButton.addEventListener("click", function() {
    channel.perform("reset_filters");
  });

  // Function to update the recipe list
  function updateRecipeList(recipes) {
    const recipesList = document.getElementById("recipes-list");
    recipesList.innerHTML = "";

    recipes.forEach(recipe => {
      const listItem = document.createElement("li");
      listItem.innerHTML = `
        <p>${recipe.title}</p>
        <p>${recipe.instructions}</p>
        <p>Rating: ${recipe.average_rating}</p>
      `;
      recipesList.appendChild(listItem);
    });
  }
});
