import 'package:flutter/cupertino.dart';

class RecipeCard extends StatefulWidget {
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
  State<RecipeCard> createState() => _RecipeCardState();
}

class _RecipeCardState extends State<RecipeCard> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    final _isDarkMode = CupertinoTheme.brightnessOf(context) == Brightness.dark;

    return GestureDetector(
      onTapDown: (_) => setState(() => isPressed = true),
      onTapUp: (_) => setState(() => isPressed = false),
      onTapCancel: () => setState(() => isPressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: widget.margin,
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          // ENHANCED BORDER FOR DARK MODE
          border: Border.all(
            color: _isDarkMode
                ? CupertinoColors.systemOrange.withOpacity(
                    0.6,
                  ) // Stronger orange border
                : const Color(0xFFD2691E).withOpacity(0.3),
            width: _isDarkMode ? 1.5 : 1.2, // Thicker border in dark mode
          ),
          // IMPROVED SHADOW SYSTEM FOR DARK MODE
          boxShadow: [
            // Primary deep shadow
            BoxShadow(
              color: _isDarkMode
                  ? CupertinoColors.black.withOpacity(
                      0.9,
                    ) // Much stronger shadow
                  : const Color(0xFF8B4513).withOpacity(0.25),
              spreadRadius: _isDarkMode ? 4 : 3, // More spread in dark mode
              blurRadius: _isDarkMode ? 30 : 25, // More blur in dark mode
              offset: Offset(
                0,
                _isDarkMode ? 15 : 12,
              ), // More offset in dark mode
            ),
            // Secondary mid-level shadow with orange glow
            BoxShadow(
              color: _isDarkMode
                  ? CupertinoColors.systemOrange.withOpacity(0.2) // Orange glow
                  : const Color(0xFFD2691E).withOpacity(0.15),
              spreadRadius: _isDarkMode ? 2 : 2,
              blurRadius: _isDarkMode ? 20 : 18,
              offset: Offset(0, _isDarkMode ? 10 : 8),
            ),
            // Close definition shadow
            BoxShadow(
              color: _isDarkMode
                  ? CupertinoColors.black.withOpacity(0.6)
                  : const Color(0xFF8B4513).withOpacity(0.12),
              spreadRadius: _isDarkMode ? 2 : 1,
              blurRadius: _isDarkMode ? 12 : 8,
              offset: Offset(0, _isDarkMode ? 6 : 4),
            ),
            // Enhanced top highlight for dark mode
            BoxShadow(
              color: _isDarkMode
                  ? CupertinoColors.white.withOpacity(
                      0.15,
                    ) // Stronger highlight
                  : CupertinoColors.white.withOpacity(0.8),
              spreadRadius: 0,
              blurRadius: _isDarkMode ? 4 : 3,
              offset: Offset(0, _isDarkMode ? -3 : -2),
            ),
            // Inner glow effect for dark mode only
            if (_isDarkMode)
              BoxShadow(
                color: CupertinoColors.systemOrange.withOpacity(0.08),
                spreadRadius: -3,
                blurRadius: 10,
                offset: const Offset(0, 0),
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
                    topLeft: Radius.circular(widget.borderRadius),
                    topRight: Radius.circular(widget.borderRadius),
                  ),
                  child: _buildImage(),
                ),
                // Action buttons overlay
                Positioned(
                  top: 12,
                  right: 12,
                  child: Row(
                    children: [
                      if (widget.onFavorite != null)
                        _buildActionButton(
                          icon: widget.isFavorite
                              ? CupertinoIcons.heart_fill
                              : CupertinoIcons.heart,
                          color: widget.isFavorite
                              ? widget.favoriteColor
                              : CupertinoColors.white,
                          onPressed: widget.onFavorite!,
                          backgroundColor: CupertinoColors.white.withOpacity(
                            0.9,
                          ),
                        ),
                      if (widget.onFavorite != null &&
                          (widget.onEdit != null || widget.onDelete != null))
                        const SizedBox(width: 8),
                      if (widget.onEdit != null)
                        _buildActionButton(
                          icon: CupertinoIcons.pencil,
                          color: widget.editColor,
                          onPressed: widget.onEdit!,
                          backgroundColor: CupertinoColors.white.withOpacity(
                            0.9,
                          ),
                        ),
                      if (widget.onEdit != null && widget.onDelete != null)
                        const SizedBox(width: 8),
                      if (widget.onDelete != null)
                        _buildActionButton(
                          icon: CupertinoIcons.trash,
                          color: widget.deleteColor,
                          onPressed: widget.onDelete!,
                          backgroundColor: CupertinoColors.white.withOpacity(
                            0.9,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            // Card content
            Padding(
              padding: widget.padding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card name
                  Text(
                    widget.cardName,
                    style:
                        widget.nameStyle ??
                        const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: CupertinoColors.black,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),

                  // Ingredients section
                  if (widget.ingredients.isNotEmpty) ...[
                    Text(
                      'Ingredients:',
                      style:
                          widget.sectionHeaderStyle ??
                          const TextStyle(
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
                  if (widget.method.isNotEmpty) ...[
                    Text(
                      'Method:',
                      style:
                          widget.sectionHeaderStyle ??
                          const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: CupertinoColors.black,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _truncateMethod(widget.method),
                      style:
                          widget.methodStyle ??
                          const TextStyle(
                            fontSize: 14,
                            color: CupertinoColors.systemGrey,
                            height: 1.4,
                          ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Tags section
                  if (widget.tags.isNotEmpty) _buildTags(),
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
      height: widget.imageHeight,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(widget.borderRadius),
          topRight: Radius.circular(widget.borderRadius),
        ),
        child: widget.imagePath.isNotEmpty
            ? _buildActualImage()
            : _buildPlaceholderImage(),
      ),
    );
  }

  Widget _buildActualImage() {
    // Check if it's a network URL (Supabase) or local asset
    if (widget.imagePath.startsWith('http://') ||
        widget.imagePath.startsWith('https://')) {
      // Network image (Supabase URL)
      return Image.network(
        widget.imagePath,
        fit: BoxFit.cover,
        height: widget.imageHeight,
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
        widget.imagePath,
        fit: BoxFit.cover,
        height: widget.imageHeight,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderImage();
        },
      );
    }
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      height: widget.imageHeight,
      width: double.infinity,
      color: CupertinoColors.systemGrey5,
      child: const Center(child: CupertinoActivityIndicator()),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      height: widget.imageHeight,
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
        child: Icon(icon, size: widget.iconSize, color: color),
      ),
    );
  }

  Widget _buildIngredientsList() {
    final displayIngredients = widget.ingredients
        .take(widget.maxIngredientsToShow)
        .toList();
    final hasMore = widget.ingredients.length > widget.maxIngredientsToShow;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...displayIngredients.map(
          (ingredient) => Padding(
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
                    style:
                        widget.ingredientStyle ??
                        const TextStyle(
                          fontSize: 14,
                          color: CupertinoColors.black,
                          height: 1.3,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (hasMore)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '+${widget.ingredients.length - widget.maxIngredientsToShow} more ingredients',
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
    if (text.length <= widget.maxMethodLength) return text;
    return '${text.substring(0, widget.maxMethodLength)}...';
  }

  Widget _buildTags() {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: widget.tags
          .map(
            (tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: widget.tagBackgroundColor,
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
                    style:
                        widget.tagStyle ??
                        const TextStyle(
                          fontSize: 12,
                          color: CupertinoColors.systemGrey,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
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
              method:
                  'Preheat oven to 375°F. 2. Mix dry ingredients. 3. Cream butter and sugars. 4. Add eggs and vanilla. 5. Combine wet and dry ingredients. 6. Fold in chocolate chips. 7. Drop spoonfuls on baking sheet. 8. Bake for 9-11 minutes until golden brown.',
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
