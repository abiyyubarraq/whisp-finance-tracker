// lib/widgets/common/cross_platform_image.dart
import 'dart:io' show File;
import 'dart:typed_data' show Uint8List;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// A cross-platform image widget that works on both web and mobile platforms.
/// Handles displaying images from XFile objects properly across all platforms.
class CrossPlatformImage extends StatelessWidget {
  final XFile imageFile;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;
  final BorderRadius? borderRadius;

  const CrossPlatformImage({
    super.key,
    required this.imageFile,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.errorBuilder,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    if (kIsWeb) {
      // On web, use Image.network with the XFile path
      imageWidget = Image.network(
        imageFile.path,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: errorBuilder,
      );
    } else {
      // On mobile/desktop, use Image.file
      imageWidget = Image.file(
        File(imageFile.path),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: errorBuilder,
      );
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}

/// Future-based version that reads bytes for web compatibility
class CrossPlatformImageFromBytes extends StatelessWidget {
  final XFile imageFile;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;
  final BorderRadius? borderRadius;

  const CrossPlatformImageFromBytes({
    super.key,
    required this.imageFile,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.errorBuilder,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: imageFile.readAsBytes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            width: width,
            height: height,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          if (errorBuilder != null) {
            return errorBuilder!(context, snapshot.error!, null);
          }
          return Container(
            width: width,
            height: height,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Icon(Icons.broken_image_rounded),
          );
        }

        final bytes = snapshot.data!;
        final imageWidget = Image.memory(
          bytes,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: errorBuilder,
        );

        if (borderRadius != null) {
          return ClipRRect(
            borderRadius: borderRadius!,
            child: imageWidget,
          );
        }

        return imageWidget;
      },
    );
  }
}
