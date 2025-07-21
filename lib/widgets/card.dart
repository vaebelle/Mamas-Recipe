import 'package:flutter/cupertino.dart';

class RecipeCard extends StatelessWidget {
  final String imagePath;
  final String cardName;
  final List<String> ingredients;
  final String method;
  final List<String> tags;
  final bool isFavorite;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onFavorite;
  final VoidCallback? onTap;
  final double borderRadius;
  final Color backgroundColor;
  final Color shadowColor;
  final double shadowOpacity;
  final double shadowBlurRadius;
  final Offset shadowOffset;
  final double imageHeight;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double iconSize;
  final Color favoriteColor;
  final Color editColor;
  final Color deleteColor;
  final TextStyle? nameStyle;
  final TextStyle? sectionHeaderStyle;
  final TextStyle? ingredientStyle;
  final TextStyle? methodStyle;
  final TextStyle? tagStyle;
  final Color tagBackgroundColor;
  final Color tagTextColor;
  final int maxIngredientsToShow;
  final int maxMethodLength;

  const RecipeCard({
    super.key,
    required this.imagePath,
    required this.cardName,
    required this.ingredients,
    required this.method,
    required this.tags,
    this.isFavorite = false,
    this.onEdit,
    this.onDelete,
    this.onFavorite,
    this.onTap,
    this.borderRadius = 16.0,
    this.backgroundColor = CupertinoColors.white,
    this.shadowColor = CupertinoColors.systemGrey4,
    this.shadowOpacity = 0.15,
    this.shadowBlurRadius = 8.0,
    this.shadowOffset = const Offset(0, 2),
    this.imageHeight = 180.0,
    this.padding = const EdgeInsets.all(16.0),
    this.margin = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    this.iconSize = 20.0,
    this.favoriteColor = CupertinoColors.systemRed,
    this.editColor = CupertinoColors.systemBlue,
    this.deleteColor = CupertinoColors.systemRed,
    this.nameStyle,
    this.sectionHeaderStyle,
    this.ingredientStyle,
    this.methodStyle,
    this.tagStyle,
    this.tagBackgroundColor = CupertinoColors.systemGrey6,
    this.tagTextColor = CupertinoColors.systemGrey,
    this.maxIngredientsToShow = 3,
    this.maxMethodLength = 100,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: shadowColor.withOpacity(shadowOpacity),
              blurRadius: shadowBlurRadius,
              offset: shadowOffset,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with placeholder
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(borderRadius),
                    topRight: Radius.circular(borderRadius),
                  ),
                  child: _buildImage(),
                ),
                // Action buttons overlay
                Positioned(
                  top: 12,
                  right: 12,
                  child: Row(
                    children: [
                      if (onFavorite != null) _buildActionButton(
                        icon: isFavorite ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                        color: isFavorite ? favoriteColor : CupertinoColors.white,
                        onPressed: onFavorite!,
                        backgroundColor: CupertinoColors.white.withOpacity(0.9),
                      ),
                      if (onFavorite != null && (onEdit != null || onDelete != null)) const SizedBox(width: 8),
                      if (onEdit != null) _buildActionButton(
                        icon: CupertinoIcons.pencil,
                        color: editColor,
                        onPressed: onEdit!,
                        backgroundColor: CupertinoColors.white.withOpacity(0.9),
                      ),
                      if (onEdit != null && onDelete != null) const SizedBox(width: 8),
                      if (onDelete != null) _buildActionButton(
                        icon: CupertinoIcons.trash,
                        color: deleteColor,
                        onPressed: onDelete!,
                        backgroundColor: CupertinoColors.white.withOpacity(0.9),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Card content
            Padding(
              padding: padding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card name
                  Text(
                    cardName,
                    style: nameStyle ?? const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  
                  // Ingredients section
                  if (ingredients.isNotEmpty) ...[
                    Text(
                      'Ingredients:',
                      style: sectionHeaderStyle ?? const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildIngredientsList(),
                    const SizedBox(height: 16),
                  ],
                  
                  // Method section
                  if (method.isNotEmpty) ...[
                    Text(
                      'Method:',
                      style: sectionHeaderStyle ?? const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _truncateMethod(method),
                      style: methodStyle ?? const TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.systemGrey,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Tags section
                  if (tags.isNotEmpty) _buildTags(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Container(
      height: imageHeight,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(borderRadius),
          topRight: Radius.circular(borderRadius),
        ),
        child: imagePath.isNotEmpty ? _buildActualImage() : _buildPlaceholderImage(),
      ),
    );
  }

  Widget _buildActualImage() {
    // Check if it's a network URL (Supabase) or local asset
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      // Network image (Supabase URL)
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        height: imageHeight,
        width: double.infinity,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLoadingPlaceholder();
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderImage();
        },
      );
    } else {
      // Local asset image
      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
        height: imageHeight,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderImage();
        },
      );
    }
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      height: imageHeight,
      width: double.infinity,
      color: CupertinoColors.systemGrey5,
      child: const Center(
        child: CupertinoActivityIndicator(),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      height: imageHeight,
      width: double.infinity,
      color: CupertinoColors.systemGrey5,
      child: const Icon(
        CupertinoIcons.photo,
        size: 48,
        color: CupertinoColors.systemGrey3,
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    Color? backgroundColor,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: backgroundColor ?? CupertinoColors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: iconSize,
          color: color,
        ),
      ),
    );
  }

  Widget _buildIngredientsList() {
    final displayIngredients = ingredients.take(maxIngredientsToShow).toList();
    final hasMore = ingredients.length > maxIngredientsToShow;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...displayIngredients.map((ingredient) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.only(top: 6, right: 8),
                decoration: const BoxDecoration(
                  color: CupertinoColors.systemOrange,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Text(
                  ingredient,
                  style: ingredientStyle ?? const TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.black,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        )),
        if (hasMore)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '+${ingredients.length - maxIngredientsToShow} more ingredients',
              style: const TextStyle(
                fontSize: 13,
                color: CupertinoColors.systemGrey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  String _truncateMethod(String text) {
    if (text.length <= maxMethodLength) return text;
    return '${text.substring(0, maxMethodLength)}...';
  }

  Widget _buildTags() {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: tags.map((tag) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: tagBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: CupertinoColors.systemGrey4,
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: CupertinoColors.systemGrey2,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              tag,
              style: tagStyle ?? const TextStyle(
                fontSize: 12,
                color: CupertinoColors.systemGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }
}

// Example usage that matches the design
class RecipeCardExample extends StatefulWidget {
  const RecipeCardExample({super.key});

  @override
  State<RecipeCardExample> createState() => _RecipeCardExampleState();
}

class _RecipeCardExampleState extends State<RecipeCardExample> {
  bool _isFavorite = true;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Recipe Cards'),
        backgroundColor: CupertinoColors.white,
      ),
      child: SafeArea(
        child: ListView(
          children: [
            const SizedBox(height: 20),
            RecipeCard(
              imagePath: 'assets/images/cookies.jpg',
              cardName: 'Classic Chocolate Chip Cookies',
              ingredients: [
                '2 cups flour',
                '1 cup butter',
                '1/2 cup brown sugar',
                '1/2 cup white sugar',
                '2 large eggs',
                '2 tsp vanilla extract',
                '1 tsp baking soda',
                '1 tsp salt',
                '2 cups chocolate chips',
              ],
              method: 'Preheat oven to 375°F. 2. Mix dry ingredients. 3. Cream butter and sugars. 4. Add eggs and vanilla. 5. Combine wet and dry ingredients. 6. Fold in chocolate chips. 7. Drop spoonfuls on baking sheet. 8. Bake for 9-11 minutes until golden brown.',
              tags: ['dessert', 'cookies', 'chocolate'],
              isFavorite: _isFavorite,
              onEdit: () {
                print('Edit recipe');
              },
              onDelete: () {
                print('Delete recipe');
              },
              onFavorite: () {
                setState(() {
                  _isFavorite = !_isFavorite;
                });
              },
              onTap: () {
                print('Open recipe details');
              },
            ),
          ],
        ),
      ),
    );
  }
}