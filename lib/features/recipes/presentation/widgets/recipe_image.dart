import 'package:flutter/material.dart';

/// Image de recette optimisée : décodée à la taille affichée (`cacheWidth`),
/// chargée à la demande, avec un visuel de remplacement hors ligne.
class RecipeImage extends StatelessWidget {
  const RecipeImage({
    super.key,
    required this.imageUrl,
    required this.width,
    required this.height,
    this.semanticLabel,
  });

  final String imageUrl;
  final double width;
  final double height;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final Widget placeholder = _ImagePlaceholder(width: width, height: height);
    if (imageUrl.isEmpty) return placeholder;

    final int cacheWidth =
        (width * MediaQuery.devicePixelRatioOf(context)).round();
    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: BoxFit.cover,
      cacheWidth: cacheWidth,
      semanticLabel: semanticLabel,
      loadingBuilder: (
        BuildContext context,
        Widget child,
        ImageChunkEvent? loadingProgress,
      ) =>
          loadingProgress == null ? child : placeholder,
      errorBuilder: (
        BuildContext context,
        Object error,
        StackTrace? stackTrace,
      ) =>
          placeholder,
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Container(
      width: width,
      height: height,
      color: colors.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(Icons.restaurant, color: colors.onSurfaceVariant),
    );
  }
}