import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:the_anti_basi/config/app_colors.dart';
import 'package:the_anti_basi/config/routes.dart';
import 'package:the_anti_basi/ui/screens/recipe/widgets/recipe_card.dart';

class RecipeSuggestion extends StatelessWidget {
  const RecipeSuggestion({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 250, // Adjust height as needed
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5, // Example count
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(left: index == 0 ? 16 : 0, right: 16),
                child: RecipeCard(
                  imageUrl: 'https://via.placeholder.com/150', // Replace with actual image
                  title: 'Spaghetti with Meatballs $index',
                  duration: '30 min',
                  rating: 4.5,
                  calories: 450,
                  onTap: () {
                    context.goNamed('recipeDetail',
                        pathParameters: {'id': index.toString()});
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}