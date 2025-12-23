import 'package:flutter/material.dart';
import 'package:the_anti_basi/config/app_colors.dart';
import 'package:the_anti_basi/ui/screens/recipe/widgets/ingredient_card.dart';
import 'package:the_anti_basi/ui/screens/recipe/widgets/instruction_card.dart';
import 'package:the_anti_basi/ui/screens/recipe/widgets/recipe_detail_header.dart';
import 'package:the_anti_basi/ui/screens/recipe/widgets/utensil_card.dart';

class RecipeDetailScreen extends StatelessWidget {
  static const String route = '/recipe_detail';

  const RecipeDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: RecipeDetailHeader(
              imageUrl: 'https://via.placeholder.com/400x250',
              title: 'Delicious Pasta with Pesto',
              description:
                  'A quick and easy pasta dish with fresh pesto, cherry tomatoes, and parmesan cheese.',
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  Text(
                    'Ingredients',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkGrey,
                        ),
                  ),
                  const SizedBox(height: 16),
                  const IngredientCard(
                    ingredientName: 'Pasta',
                    quantity: '200g',
                  ),
                  const SizedBox(height: 8),
                  const IngredientCard(
                    ingredientName: 'Pesto Sauce',
                    quantity: '100g',
                  ),
                  const SizedBox(height: 8),
                  const IngredientCard(
                    ingredientName: 'Cherry Tomatoes',
                    quantity: '1 cup',
                  ),
                  const SizedBox(height: 8),
                  const IngredientCard(
                    ingredientName: 'Parmesan Cheese',
                    quantity: '50g',
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Instructions',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkGrey,
                        ),
                  ),
                  const SizedBox(height: 16),
                  const InstructionCard(
                    stepNumber: 1,
                    instruction:
                        'Boil pasta according to package directions until al dente.',
                  ),
                  const SizedBox(height: 8),
                  const InstructionCard(
                    stepNumber: 2,
                    instruction:
                        'Drain pasta and return to the pot. Stir in pesto sauce and cherry tomatoes.',
                  ),
                  const SizedBox(height: 8),
                  const InstructionCard(
                    stepNumber: 3,
                    instruction:
                        'Serve hot, topped with grated parmesan cheese.',
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Utensils',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkGrey,
                        ),
                  ),
                  const SizedBox(height: 16),
                  const UtensilCard(
                    utensilName: 'Large Pot',
                    icon: Icons.soup_kitchen,
                  ),
                  const SizedBox(height: 8),
                  const UtensilCard(
                    utensilName: 'Colander',
                    icon: Icons.filter_alt,
                  ),
                  const SizedBox(height: 8),
                  const UtensilCard(
                    utensilName: 'Mixing Spoon',
                    icon: Icons.restaurant_menu,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}