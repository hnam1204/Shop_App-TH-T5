import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/app_config.dart';

class AppNetworkImage extends StatelessWidget {
  final String? imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final IconData fallbackIcon;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;

  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.fallbackIcon = Icons.image_not_supported_outlined,
    this.borderRadius,
    this.backgroundColor,
  });

  static final Set<String> _loggedErrors = <String>{};

  @override
  Widget build(BuildContext context) {
    final source = imageUrl?.trim() ?? '';
    final child = _buildImage(context, source);

    if (borderRadius == null) return child;

    return ClipRRect(borderRadius: borderRadius!, child: child);
  }

  Widget _buildImage(BuildContext context, String source) {
    if (source.isEmpty) {
      return _fallback(context);
    }

    if (_isAsset(source)) {
      return Image.asset(
        source,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          _logImageError(source, error);
          return _fallback(context);
        },
      );
    }

    final safeUrl = getSafeImageUrl(source);
    if (kIsWeb) {
      return Image.network(
        safeUrl,
        width: width,
        height: height,
        fit: fit,
        webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _placeholder(context);
        },
        errorBuilder: (context, error, stackTrace) {
          _logImageError(source, error);
          return _fallback(context);
        },
      );
    }

    return CachedNetworkImage(
      imageUrl: safeUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => _placeholder(context),
      errorWidget: (context, url, error) {
        _logImageError(source, error);
        return _fallback(context);
      },
    );
  }

  bool _isAsset(String source) {
    return source.startsWith('assets/');
  }

  Widget _placeholder(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: width,
      height: height,
      color: backgroundColor ?? colorScheme.primary.withValues(alpha: 0.08),
      alignment: Alignment.center,
      child: SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.2,
          color: colorScheme.primary,
        ),
      ),
    );
  }

  Widget _fallback(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: width,
      height: height,
      color: backgroundColor ?? colorScheme.primary.withValues(alpha: 0.08),
      alignment: Alignment.center,
      child: Icon(fallbackIcon, color: colorScheme.primary, size: 36),
    );
  }

  void _logImageError(String source, Object error) {
    if (source.isEmpty || _loggedErrors.contains(source)) return;
    _loggedErrors.add(source);
    debugPrint('AppNetworkImage failed: $source ($error)');
  }
}
