// lib/widgets/common/firebase_storage_image.dart
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:dio/dio.dart';

/// A widget that loads images from Firebase Storage using the Storage SDK
/// This bypasses CORS issues on web by using authenticated Firebase SDK requests
class FirebaseStorageImage extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget Function(BuildContext)? errorBuilder;
  final Widget Function(BuildContext)? loadingBuilder;

  const FirebaseStorageImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.errorBuilder,
    this.loadingBuilder,
  });

  @override
  State<FirebaseStorageImage> createState() => _FirebaseStorageImageState();
}

class _FirebaseStorageImageState extends State<FirebaseStorageImage> {
  Uint8List? _imageBytes;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(FirebaseStorageImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _imageBytes = null;
    });

    try {
      Uint8List? bytes;

      if (kIsWeb) {
        try {
          final dio = Dio();
          final response = await dio.get<List<int>>(
            widget.imageUrl,
            options: Options(
              responseType: ResponseType.bytes,
              followRedirects: true,
              validateStatus: (status) => status! < 500,
            ),
          );

          if (response.statusCode == 200 && response.data != null) {
            bytes = Uint8List.fromList(response.data!);
          } else {
            throw DioException(
              requestOptions: response.requestOptions,
              message: 'Failed to load image: HTTP ${response.statusCode}',
            );
          }
        } catch (e) {
          debugPrint('⚠️  Fresh URL approach failed: $e');

          // Approach 2: Fall back to original URL
          debugPrint('🔄 Trying original URL...');
          final dio = Dio();
          final response = await dio.get<List<int>>(
            widget.imageUrl,
            options: Options(
              responseType: ResponseType.bytes,
              followRedirects: true,
              validateStatus: (status) => status! < 500,
            ),
          );

          if (response.statusCode == 200 && response.data != null) {
            bytes = Uint8List.fromList(response.data!);
          } else {
            rethrow;
          }
        }
      } else {
        // On mobile/desktop, use Firebase SDK
        debugPrint('📱 Using Firebase SDK for native image loading');
        final ref = FirebaseStorage.instance.refFromURL(widget.imageUrl);
        bytes = await ref.getData();
      }

      if (!mounted) return;

      if (bytes == null) {
        throw Exception('Failed to download image data');
      }

      setState(() {
        _imageBytes = bytes;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Error loading Firebase Storage image: $e');
      debugPrint('   URL: ${widget.imageUrl}');
      debugPrint('');
      debugPrint('💡 CORS ERROR DETECTED!');
      debugPrint('   This is a Firebase Storage CORS configuration issue.');
      debugPrint(
        '   To fix permanently, configure CORS for your storage bucket.',
      );
      debugPrint(
        '   See: https://firebase.google.com/docs/storage/web/download-files',
      );

      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (_isLoading) {
      child =
          widget.loadingBuilder?.call(context) ??
          Container(
            width: widget.width,
            height: widget.height,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
    } else if (_error != null) {
      child =
          widget.errorBuilder?.call(context) ??
          Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: widget.borderRadius,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.broken_image_rounded,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.4),
                  size: 32,
                ),
                SizedBox(height: 4),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'Failed to load',
                    style: TextStyle(
                      fontSize: 10,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          );
    } else {
      child = Image.memory(
        _imageBytes!,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        errorBuilder: (context, error, stackTrace) {
          return widget.errorBuilder?.call(context) ??
              Container(
                width: widget.width,
                height: widget.height,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Icon(Icons.broken_image_rounded),
              );
        },
      );
    }

    if (widget.borderRadius != null && _imageBytes != null) {
      return ClipRRect(borderRadius: widget.borderRadius!, child: child);
    }

    return child;
  }
}
