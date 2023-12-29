import ActionCable from 'actioncable';

class RecipesApp {
  constructor() {
    const webSocketUrl = document.querySelector('h1').dataset.webSocketUrl;

    this.cable = ActionCable.createConsumer(webSocketUrl);
    this.channelId = this.generateChannelId();
    this.recipesChannel = this.initRecipesChannel();
    this.setupEventListeners();

    this.selectedIngredients = [];
  }

  // Clients should get tokens from the server to ensure uniqueness,
  // but for the demo purposes it should be fine. And there is no
  generateChannelId() {
    const timestamp = new Date().getTime().toString(36);
    const randomString = Math.random().toString(36).substring(2, 10);

    return `${timestamp}_${randomString}`;
  }

  initRecipesChannel() {
    return this.cable.subscriptions.create(
      {
        channel: 'RecipesChannel',
        channel_id: this.channelId,
      },
      {
        connected: () => this.performFilterRecipes({ rating: null, ingredients_ids: null }),
        disconnected: () => console.log('Disconnected from RecipesChannel'),
        received: (data) => {
          if (data.recipes) {
            this.updateRecipesList(data.recipes);
          }
        },
        filter_recipes: (data) => this.performFilterRecipes(data),
      }
    );
  }

  performFilterRecipes(data) {
    this.recipesChannel.perform('filter_recipes', data);
  }

  updateRecipesList(recipes) {
    const recipesList = document.getElementById('recipes-list');
    recipesList.innerHTML = '';
  
    recipes.forEach((recipe) => {
      let recipe_html  = `
        <div class="card mb-2" style="width: 80rem;">
          <div class="card-body">
            <h4 class="card-title text-center">${recipe.title}</h5>
            <p class="text-center">Rating: ${recipe.rating} </p>
            <div class="card-text">
              <b>Ingredients:</b>
              <ul>
                ${this.composeIngredientsList(recipe)}
              </ul>
              <p class="mt-2"><b>Instructions:</b></p>
              ${recipe.instructions.substring(0, 333) + '...'}
              <br>
              <div class="text-center">
                <a href="#" class="btn btn-primary disabled mt-2">Read the recipe</a>
              </div>
            </div>
          </div>
        </div>
      `;
      recipesList.innerHTML += recipe_html;
    });
  }

  composeIngredientsList(recipe) {
    return recipe.recipe_ingredients.map(ingredient =>
      `<li>${ingredient.ingredient.name} (${ingredient.quantity})</li>`
    ).join('')
  }

  setupEventListeners() {
    this.setupRatingFilterListener();
    this.setupIngredientButtonsListener();
    this.setupResetFiltersButtonListener();
  }

  // Filtering by ingredients

  setupIngredientButtonsListener() {
    const thiz = this;
    const ingredientButtons = document.querySelectorAll('.ingredient-filter-btn');

    ingredientButtons.forEach((button) => {
      button.addEventListener('click', () => {
        const ingredientId = button.dataset.ingredientId;

        thiz.toggleIngredientSelection(ingredientId);

        // It could be refactored to use this.rating in every listener that needs this value
        // For now I'm leaving it as it is because I'm
        const ratingFilter = document.getElementById('recipes-rating-slider');
        const rating = parseFloat(ratingFilter.value);

        thiz.recipesChannel.filter_recipes({ rating: rating, ingredients_ids: thiz.selectedIngredients });

        thiz.updateIngredientButtonsUI();
      });
    });
  }

  toggleIngredientSelection(ingredientId) {
    const index = this.selectedIngredients.indexOf(ingredientId);

    if (index === -1) { // Ingredient is not selected, add to the list
      this.selectedIngredients.push(ingredientId);
    } else { // Ingredient selected, remove from the list
      this.selectedIngredients.splice(index, 1);
    }
  }

  updateIngredientButtonsUI() {
    const ingredientButtons = document.querySelectorAll('.ingredient-filter-btn');
    ingredientButtons.forEach((button) => {
      const ingredientId = button.dataset.ingredientId;
      const isSelected = this.selectedIngredients.includes(ingredientId);
      if (isSelected) {
        button.classList.remove('btn-outline-secondary');
        button.classList.add('btn-outline-success');
      } else {
        button.classList.remove('btn-outline-success');
        button.classList.add('btn-outline-secondary');
      }
    });
  }

  setupResetFiltersButtonListener() {
    const resetFiltersButton = document.getElementById('reset-filters');

    resetFiltersButton.addEventListener('click', () => {
      this.recipesChannel.filter_recipes({ rating: null, ingredients_ids: null });

      document.getElementById('recipes-rating-slider').value = 0;

      document.querySelectorAll('.ingredient-filter-btn').forEach((button) => {
        button.classList.remove('btn-outline-success');
        button.classList.add('btn-outline-secondary');
      });
    });
  }

  // Filtering by rating

  setupRatingFilterListener() {
    const thiz = this;
    const ratingFilter = document.getElementById('recipes-rating-slider');

    ratingFilter.addEventListener('input', () => {
      const rating = parseFloat(ratingFilter.value);
      this.updateRatingTooltip(rating);
    });

    ratingFilter.addEventListener('change', () => {
      const rating = parseFloat(ratingFilter.value);
      this.recipesChannel.filter_recipes({ rating: rating, ingredients_ids: thiz.selectedIngredients });
    });
  }

  updateRatingTooltip(rating) {
    document.getElementById('rating-tooltip').innerText = 'Rating: ' + rating.toFixed(1);
  }
}

document.addEventListener('DOMContentLoaded', () => {
  new RecipesApp();
});
