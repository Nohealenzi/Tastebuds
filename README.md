# TasteBuds

## Table of Contents

1. [Overview](#Overview)
2. [Product Spec](#Product-Spec)
3. [Wireframes](#Wireframes)
4. [Schema](#Schema)

## Overview
![Untitled1-ezgif com-video-to-gif-converter](https://github.com/user-attachments/assets/c117993a-1eed-49f5-b4a4-9b88eac96450)
![Untitled2-ezgif com-video-to-gif-converter](https://github.com/user-attachments/assets/c90bd05f-a1c9-45d6-a801-e730f18ca23e)

### Description

TasteBuds is an app designed for cooking enthusiasts and home chefs to challenge or better their cooking capabilities. Its main purpose is to help users discover recipes based on the ingredients they currently have, encouraging creativity and reducing food waste. The main core dynamic is to provide its users with cooking recipes based on their current ingredients. Additional features include a challenge mode where users get random ingredients or select a cooking theme, create recipes, and have them rated by the community.

### App Evaluation

- **Category:** Educational, Health, Nutrition, Education, Social
- **Mobile:** No, app is available for mobile and tablets.
- **Story:**  This app facilitates its users day to day meal preparation process. Instead of having random ingredients that the user wouldn't know what they make with, the app takes those ingredients and gives them a list of recipes. Additionally, they can share their own recipes to add to the list, and share them with the community to get reviews and helpful tips on what can be done to improve them.
- **Market:** The target audience for this app is culinary enthusiasts. People who wish to expand on their culinary knowledge, and people who are just getting started alike.
- **Habit:** Its intention is to be a daily app, however, I predict that it would be used occasionally.
- **Scope:** The basic version would be relatively narrow. However, there is a lot of space for scalability and new features to be added.

## Product Spec

### 1. User Stories (Required and Optional)

**Required Must-have Stories**

* User can sign up for the app and login.
* User can input one or more ingredients to search for recipe.
* User can browse list of recipes based on search. 
* User can view a detailed recipe, including ingredients and instructions.
* User can save recipe to their profile.


**Optional Nice-to-have Stories**

* User can select themed recipe categories (e.g., "Quick Meals," "Vegan Options").
* User can post their own recipes including photos and instructions.
* User can comment on recipes and rate them.
* User can participate in community challenges (e.g., cook with random ingredients).
* User can receive personalized recipe suggestions based on their preferences.
* User can filter recipes by dietary restrictions or preparation time.

### 2. Screen Archetypes

- [x] [**Login Screen**]
* User can log in.
- [x] [**Home Screen**]
* User can choose to do an ingredient based search or to browse all recipes.
- [ ] [**Ingredient Input Screen**]- removed this idea
* User can input an ingredient and initiate a search
- [x] [**Recipes List Screen**]
* User can view search results or browse all recipes
- [x] [**Recipe Detail Screen**]
* User can view all details about a selected recipe
- [x] [**Saved Recipes Screen**]
* User can view a list of saved recipes(Optional)
- [ ] [**Community Screen (Optional)**]
* User can browse user-submitted recipes and participate in challenges.
- [ ] [**Challenge Details Screen (Optional)**]
* User can browse user-submitted recipes and participate in challenges.


### 3. Navigation

**Tab Navigation** (Tab to Screen)


- [x] [Home Tab] - Access ingredients search and browse options
- [x] [All Recipes Tab] - View all availabe recipes
- [x] [Saved Recipes Tab] - Access saved recipes
- [ ] [Community Tab (Optional)] - Explore challenges and community recipes

**Flow Navigation** (Screen to Screen)

- [x] [**Login Screen**]
  * Leads to [**Home Screen**]
- [x] [**Home Screen**]
  * Leads to [**Ingredient Input Screen**], [**All Recipes List Screen**], [**Saved Recipes Screen**]
- [ ] [**Ingredient Input Screen**] - not necessary since input screen was removed
  * Leads to [**Recipe List Screen**]
- [x] [**Recipe List Screen**]
  * Leads to [**Recipe Detail Screen**]
- [x] [**All Recipes List Screen**]
  * Leads to [**Recipe Detail Screen**]
- [x] [**Saved Recipes Screen**]
  * Leads to [**Recipe Detail Screen**]
- [ ] [**Community Screen**]**(Optional)**
  * Leads to [**Recipe Detail Screen**], [**Challenge Details Screen**]

## Wireframes

<img width="1010" alt="Screenshot 2024-12-03 at 9 42 55 PM" src="https://github.com/user-attachments/assets/720cce54-9e95-4270-bbdf-623c71868c04">



### [BONUS] Interactive Prototype

## Schema 


### Models

[User]
| Property | Type   | Description                                  |
|----------|--------|----------------------------------------------|
| username | String | unique id for the user post |
| password | String | user's password for login authentication      |
| email | String | user's email for account recovery|
|savedRecipes | Array | list of saved recipe ID's|

[Recipe]
| Property | Type   | Description                                  |
|----------|--------|----------------------------------------------|
| recipeName | String | unique id for recipe title |
| ingredient | Array  |list of ingredients required|
|instructions | String | detailed preparation instructions |
| image | URL | image URL for the recipe |
|userRating | Float | average user rating (1-5 stars) |

[Comment] (Optional)
| Property | Type   | Description                                  |
|----------|--------|----------------------------------------------|
| content | String | content of comment |
| author | Pointer | reference to user who commented |
| recipe | Pointer | reference to the associated recipe |

### Networking
#### Login Screen
- **[POST] /login** - Authenticate user 
- **[POST] /signup** - Register a new user 

#### Home Screen
- **[GET] /recipes** - Fetch all recipes or filter by category
- **[GET] /challenges** - Fetch active challenges (Optional)

#### Ingredient Input Screen
- **[GET] /recipes?ingredients={ingredients}** - Fetch recipes matching the input ingredients

#### Recipe List Screen
- **[GET] /recipes** - Fetch recipes based on filters or themes

#### Recipe Detail Screen
- **[GET] /recipes/{recipeId}** - Fetch details of a specific recipe
- **[POST] /recipes/{recipeId}/rate** - Submit a rating for a recipe
- **[POST] /recipes/{recipeId}/comment** - Add a comment (Optional)

#### Saved Recipes Screen
- **[GET] /users/{userId}/savedRecipes** - Fetch saved recipes for the user
- **[POST] /recipes/{recipeId}/save** - Save a recipe to the user’s profile

#### Community Screen (Optional)
- **[GET] /community/recipes** - Fetch user-submitted recipes
- **[POST] /challenges/participate** - Join a cooking challenge

