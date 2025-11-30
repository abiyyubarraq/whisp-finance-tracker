// lib/widgets/common/image_attachment_widget.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../glass_container.dart';
import '../../config/theme.dart';
import '../../models/receipt_image.dart';
import 'cross_platform_image.dart';
import 'firebase_storage_image.dart';

/// A reusable widget for multiple image attachment functionality
/// Supports selecting from camera/gallery, previewing, and deleting images
/// Works cross-platform (mobile, web, desktop)
class ImageAttachmentWidget extends StatelessWidget {
  /// List of local XFiles that have been selected but not yet uploaded
  final List<XFile> selectedFiles;

  /// List of receipt images (already uploaded)
  final List<ReceiptImage> receiptImages;

  /// Whether an upload/delete operation is in progress
  final bool isLoading;

  /// Callback when new images are selected
  final ValueChanged<List<XFile>> onImagesSelected;

  /// Callback when a local file should be removed (by index)
  final ValueChanged<int> onLocalFileRemoved;

  /// Callback when an uploaded image should be removed (by ReceiptImage)
  final ValueChanged<ReceiptImage> onUploadedImageRemoved;

  /// Optional label for the widget
  final String label;

  /// Maximum number of images allowed
  final int maxImages;

  const ImageAttachmentWidget({
    super.key,
    this.selectedFiles = const [],
    this.receiptImages = const [],
    this.isLoading = false,
    required this.onImagesSelected,
    required this.onLocalFileRemoved,
    required this.onUploadedImageRemoved,
    this.label = 'Receipt Images (Optional)',
    this.maxImages = 5,
  });

  int get _totalImages => selectedFiles.length + receiptImages.length;
  bool get _canAddMore => _totalImages < maxImages;
  bool get _hasImages => _totalImages > 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            if (_hasImages)
              Text(
                '$_totalImages / $maxImages',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
          ],
        ),
        SizedBox(height: 12),
        if (_hasImages)
          _buildImageGrid(context)
        else
          _buildEmptyState(context),
        if (_canAddMore && _hasImages) ...[
          SizedBox(height: 12),
          _buildAddMoreButton(context),
        ],
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassContainer(
      padding: EdgeInsets.all(20),
      child: InkWell(
        onTap: isLoading ? null : () => _showImageSourceDialog(context),
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? AppTheme.gradientDark
                        : AppTheme.gradientLight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.add_photo_alternate_rounded,
                  size: 32,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Add Receipt Images',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 4),
              Text(
                'Tap to take photo or choose from gallery',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageGrid(BuildContext context) {
    return GlassContainer(
      padding: EdgeInsets.all(12),
      child: Column(
        children: [
          // Uploaded images
          if (receiptImages.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: receiptImages
                  .map((receiptImage) => _buildUploadedImageTile(context, receiptImage))
                  .toList(),
            ),
            if (selectedFiles.isNotEmpty) SizedBox(height: 8),
          ],
          // Local files
          if (selectedFiles.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: selectedFiles.asMap().entries.map((entry) {
                return _buildLocalFileTile(context, entry.key, entry.value);
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildUploadedImageTile(BuildContext context, ReceiptImage receiptImage) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () => _showFullImage(context, receiptImage.url),
          child: FirebaseStorageImage(
            imageUrl: receiptImage.url,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
            borderRadius: BorderRadius.circular(8),
            errorBuilder: (context) => _buildErrorTile(context),
          ),
        ),
        // Cloud icon to indicate uploaded
        Positioned(
          bottom: 4,
          left: 4,
          child: Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(Icons.cloud_done, size: 12, color: Colors.white),
          ),
        ),
        // Delete button
        if (!isLoading)
          Positioned(
            top: 4,
            right: 4,
            child: _buildDeleteButton(
              context,
              onTap: () => _confirmRemoveUploadedImage(context, receiptImage),
            ),
          ),
      ],
    );
  }

  Widget _buildLocalFileTile(BuildContext context, int index, XFile file) {
    return Stack(
      children: [
        CrossPlatformImageFromBytes(
          imageFile: file,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          borderRadius: BorderRadius.circular(8),
          errorBuilder: (context, error, stackTrace) => _buildErrorTile(context),
        ),
        // Pending upload indicator
        Positioned(
          bottom: 4,
          left: 4,
          child: Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(Icons.cloud_upload, size: 12, color: Colors.white),
          ),
        ),
        // Loading overlay
        if (isLoading)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              ),
            ),
          ),
        // Delete button
        if (!isLoading)
          Positioned(
            top: 4,
            right: 4,
            child: _buildDeleteButton(
              context,
              onTap: () => onLocalFileRemoved(index),
            ),
          ),
      ],
    );
  }

  Widget _buildErrorTile(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.broken_image_rounded,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context, {required VoidCallback onTap}) {
    return Material(
      color: Colors.red.withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(4),
          child: Icon(Icons.close, size: 14, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildAddMoreButton(BuildContext context) {
    return TextButton.icon(
      onPressed: isLoading ? null : () => _showImageSourceDialog(context),
      icon: Icon(Icons.add_photo_alternate_rounded, size: 18),
      label: Text('Add More Images (${maxImages - _totalImages} remaining)'),
    );
  }

  void _showImageSourceDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _ImageSourceBottomSheet(
        onCameraSelected: () {
          Navigator.pop(context);
          _pickImage(context, ImageSource.camera);
        },
        onGallerySelected: () {
          Navigator.pop(context);
          _pickMultipleImages(context);
        },
      ),
    );
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1920,
      maxHeight: 1920,
    );

    if (pickedFile != null) {
      onImagesSelected([pickedFile]);
    }
  }

  Future<void> _pickMultipleImages(BuildContext context) async {
    final picker = ImagePicker();
    final remainingSlots = maxImages - _totalImages;

    final pickedFiles = await picker.pickMultiImage(
      imageQuality: 85,
      maxWidth: 1920,
      maxHeight: 1920,
      limit: remainingSlots,
    );

    if (pickedFiles.isNotEmpty) {
      // Limit to remaining slots
      final limitedFiles = pickedFiles.take(remainingSlots).toList();
      onImagesSelected(limitedFiles);
    }
  }

  void _confirmRemoveUploadedImage(BuildContext context, ReceiptImage receiptImage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove Image'),
        content: Text('Are you sure you want to remove this image? It will be deleted from storage.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onUploadedImageRemoved(receiptImage);
            },
            child: Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showFullImage(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _FullImageScreen(imageUrl: imageUrl),
      ),
    );
  }
}

/// Bottom sheet for selecting image source
class _ImageSourceBottomSheet extends StatelessWidget {
  final VoidCallback onCameraSelected;
  final VoidCallback onGallerySelected;

  const _ImageSourceBottomSheet({
    required this.onCameraSelected,
    required this.onGallerySelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Select Image Source',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildSourceOption(
                      context,
                      icon: Icons.camera_alt_rounded,
                      label: 'Camera',
                      subtitle: 'Take a photo',
                      onTap: onCameraSelected,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildSourceOption(
                      context,
                      icon: Icons.photo_library_rounded,
                      label: 'Gallery',
                      subtitle: 'Select multiple',
                      onTap: onGallerySelected,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSourceOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassContainer(
      padding: EdgeInsets.all(16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? AppTheme.gradientDark
                        : AppTheme.gradientLight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 28, color: Colors.white),
              ),
              SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Full screen image viewer
class _FullImageScreen extends StatelessWidget {
  final String imageUrl;

  const _FullImageScreen({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: FirebaseStorageImage(
            imageUrl: imageUrl,
            fit: BoxFit.contain,
            loadingBuilder: (context) => Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
            errorBuilder: (context) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.broken_image_rounded, size: 64, color: Colors.white54),
                  SizedBox(height: 16),
                  Text(
                    'Failed to load image',
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Please check your connection and try again',
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
