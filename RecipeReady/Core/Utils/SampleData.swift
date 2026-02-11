//
//  SampleData.swift
//  RecipeReady
//
//  Shared sample data for seeding and UI placeholders.
//

import Foundation

struct SampleData {
    // 1. Featured Recipe (Hero)
    static var featured: Recipe {
        Recipe(
            title: "Casseroles are the Best Kick-off for Autumn",
            author: "Eitan Bernath",
            isFeatured: true,
            ingredients: [Ingredient(name: "Pasta", amount: "500g"), Ingredient(name: "Cheese", amount: "200g")],
            steps: [CookingStep(order: 1, instruction: "Bake it.")],
            imageURL: "https://images.unsplash.com/photo-1547516508-4c1f9c7c4ec3?auto=format&fit=crop&w=800&q=80", // Placeholder
            difficulty: "Medium",
            prepTime: 20,
            cookingTime: 45,
            servings: 4
        )
    }

    // 4. Eitan's Static Recipes (Eitan Eats the world)
    static var eitanStaticRecipes: [Recipe] {
        [
            Recipe(
                title: "Barbecue Burgers with Crispy Onion Straws",
                author: "Eitan Bernath",
                ingredients: [
                    Ingredient(name: "Ground beef (80/20)", amount: "1 1/2 pounds"),
                    Ingredient(name: "Brioche buns", amount: "4"),
                    Ingredient(name: "Large white onion", amount: "1"),
                    Ingredient(name: "Ketchup", amount: "1/2 cup"),
                    Ingredient(name: "Pineapple juice", amount: "1/3 cup"),
                    // Detailed ingredients implied
                ],
                steps: [
                    CookingStep(order: 1, instruction: "In a small saucepot over medium heat, combine all BBQ sauce ingredients and bring to a simmer. Cook for 15 to 20 minutes, stirring occasionally, until thickened."),
                    CookingStep(order: 2, instruction: "While BBQ sauce simmers, prepare to fry the onions. Heat 2 inches of vegetable oil to 375F. Slice onion into very thin rings."),
                    CookingStep(order: 3, instruction: "Coat onions in yogurt/milk mixture, then flour mixture. Fry for 3-4 minutes until golden brown."),
                    CookingStep(order: 4, instruction: "Form beef into 4 patties. Season and cook in skillet for 3-4 minutes per side."),
                    CookingStep(order: 5, instruction: "Assemble burgers with mayo, lettuce, tomato, pickles, onion straws, and BBQ sauce.")
                ],
                imageURL: "recipe1", // Asset name
                difficulty: "Medium",
                prepTime: 35,
                cookingTime: 45,
                servings: 4
            ),
            Recipe(
                title: "Aloo Tikki Chaat",
                author: "Eitan Bernath",
                ingredients: [
                    Ingredient(name: "Russet potatoes", amount: "5"),
                    Ingredient(name: "Green chili", amount: "1"),
                    Ingredient(name: "Cilantro", amount: "1/4 cup"),
                    Ingredient(name: "Breadcrumbs", amount: "1/4 cup"),
                    // Detailed ingredients implied
                ],
                steps: [
                    CookingStep(order: 1, instruction: "Boil potatoes until fork tender. Drain and mash with spices, chili, cilantro, and breadcrumbs."),
                    CookingStep(order: 2, instruction: "Form into patties and coat in flour."),
                    CookingStep(order: 3, instruction: "Fry patties in oil at 375°F for 2-3 minutes per side until golden brown."),
                    CookingStep(order: 4, instruction: "Serve topped with chutneys, yogurt, onion, and sev.")
                ],
                imageURL: "recipe2", // Asset name
                difficulty: "Medium",
                prepTime: 20,
                cookingTime: 25,
                servings: 8
            ),
            Recipe(
                title: "Leftover Cranberry Sauce Tart",
                author: "Eitan Bernath",
                ingredients: [
                    Ingredient(name: "Cranberry sauce", amount: "2 cups"),
                    Ingredient(name: "Almond flour", amount: "2 cups"),
                    Ingredient(name: "Powdered sugar", amount: "1/2 cup"),
                    Ingredient(name: "Butter", amount: "1 stick"),
                    // Detailed ingredients implied
                ],
                steps: [
                    CookingStep(order: 1, instruction: "Mix dry ingredients. Add butter and mix until shaggy dough forms."),
                    CookingStep(order: 2, instruction: "Press dough into tart pan. Freeze for 20 minutes."),
                    CookingStep(order: 3, instruction: "Bake at 350°F for 15-20 minutes until golden brown."),
                    CookingStep(order: 4, instruction: "Cool completely, then fill with cranberry sauce.")
                ],
                imageURL: "recipe3", // Asset name
                difficulty: "Easy",
                prepTime: 30,
                cookingTime: 20,
                servings: 8
            )
        ]
    }

}
