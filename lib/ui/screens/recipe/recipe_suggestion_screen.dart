import 'package:flutter/material.dart';
import 'package:the_anti_basi/config/app_colors.dart';
import 'package:the_anti_basi/ui/screens/recipe/widgets/recipe_header.dart';
import 'package:the_anti_basi/ui/screens/recipe/widgets/recipe_suggestion.dart';

class RecipeSuggestionScreen extends StatelessWidget {
  static const String route = '/recipe_suggestions';

  const RecipeSuggestionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: RecipeHeader(
                  title: 'Cooking with what expires soon',
                  subtitle: 'Urgent',
                  icon: Icons.timer,
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
              SizedBox(height: 24),
              RecipeSuggestion(),
              SizedBox(height: 24),
              // You can add more sections here, e.g., "Popular Recipes"
            ],
          ),
        ),
      ),
    );
  }
}