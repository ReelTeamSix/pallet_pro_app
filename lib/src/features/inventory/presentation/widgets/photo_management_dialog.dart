import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pallet_pro_app/src/features/inventory/data/models/item_photo.dart';
import '../services/photo_management_service.dart';
import 'image_preview_dialog.dart';

/// A dialog for managing item photos with a 3-photo limit
/// Shows existing photos and allows adding/removing photos
class PhotoManagementDialog extends ConsumerStatefulWidget {
  final String itemId;
  final List<ItemPhoto> existingPhotos;
  final Function() onSave;
  final Function() onCancel;

  const PhotoManagementDialog({
    Key? key,
    required this.itemId,
    required this.existingPhotos,
    required this.onSave,
    required this.onCancel,
  }) : super(key: key);

  @override
  ConsumerState<PhotoManagementDialog> createState() => _PhotoManagementDialogState();
}

class _PhotoManagementDialogState extends ConsumerState<PhotoManagementDialog> {
  static const int _maxPhotos = 3;
  
  // Track photos to keep, add, and remove
  final List<ItemPhoto> _photosToKeep = [];
  final List<XFile> _newPhotos = [];
  final List<ItemPhoto> _photosToRemove = [];

  @override
  void initState() {
    super.initState();
    // Initialize with existing photos
    _photosToKeep.addAll(widget.existingPhotos);
  }

  int get _totalPhotos => _photosToKeep.length + _newPhotos.length;
  int get _remainingSlots => _maxPhotos - _totalPhotos;

  Future<void> _pickFromGallery() async {
    if (_remainingSlots <= 0) {
      _showSnackBar('Maximum of $_maxPhotos photos allowed');
      return;
    }

    final picker = ImagePicker();
    final selectedImages = await picker.pickMultiImage();
    
    if (selectedImages.isNotEmpty) {
      final imagesToAdd = selectedImages.length <= _remainingSlots 
          ? selectedImages 
          : selectedImages.sublist(0, _remainingSlots);
      
      setState(() {
        _newPhotos.addAll(imagesToAdd);
      });
      
      if (selectedImages.length > _remainingSlots) {
        _showSnackBar('Only added $_remainingSlots of ${selectedImages.length} selected images');
      }
    }
  }

  Future<void> _takePhoto() async {
    if (_remainingSlots <= 0) {
      _showSnackBar('Maximum of $_maxPhotos photos allowed');
      return;
    }

    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    
    if (image != null) {
      setState(() {
        _newPhotos.add(image);
      });
    }
  }

  void _removeExistingPhoto(int index) {
    setState(() {
      _photosToRemove.add(_photosToKeep[index]);
      _photosToKeep.removeAt(index);
    });
  }

  void _removeNewPhoto(int index) {
    setState(() {
      _newPhotos.removeAt(index);
    });
  }

  void _restorePhoto(ItemPhoto photo) {
    setState(() {
      _photosToRemove.remove(photo);
      _photosToKeep.add(photo);
    });
  }

  void _setPrimaryPhoto(ItemPhoto photo) {
    setState(() {
      // Remove primary status from all photos
      for (final p in _photosToKeep) {
        // Note: This would need to be handled by the repository
        // For now, we'll just update the UI state
      }
      // Set the selected photo as primary
      // This would also need repository integration
    });
  }

  void _showPhotoPreview(ItemPhoto photo) {
    showDialog(
      context: context,
      builder: (context) => ImagePreviewDialog(
        existingPhoto: photo,
        isPrimary: photo.isPrimary,
        onDelete: () => _removeExistingPhoto(_photosToKeep.indexOf(photo)),
        onSetPrimary: () => _setPrimaryPhoto(photo),
      ),
    );
  }

  void _showNewPhotoPreview(XFile photo) {
    showDialog(
      context: context,
      builder: (context) => ImagePreviewDialog(
        newPhoto: photo,
        onDelete: () => _removeNewPhoto(_newPhotos.indexOf(photo)),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _saveChanges() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Use the photo management service
      final photoService = ref.read(photoManagementServiceProvider);
      
      await photoService.updateItemPhotos(
        itemId: widget.itemId,
        photosToKeep: _photosToKeep,
        newPhotos: _newPhotos,
        photosToRemove: _photosToRemove,
      );

      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
        Navigator.of(context).pop(); // Close photo management dialog
        widget.onSave();
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
        _showSnackBar('Error updating photos: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Manage Photos',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$_totalPhotos of $_maxPhotos',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: _totalPhotos >= _maxPhotos 
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _remainingSlots > 0 ? _pickFromGallery : null,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _remainingSlots > 0 ? _takePhoto : null,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Photos grid
            Expanded(
              child: PhotoGridWidget(
                existingPhotos: _photosToKeep,
                newPhotos: _newPhotos,
                onExistingPhotoTap: (photo) => _showPhotoPreview(photo),
                onNewPhotoTap: (photo) => _showNewPhotoPreview(photo),
                onExistingPhotoDelete: (photo) => _removeExistingPhoto(_photosToKeep.indexOf(photo)),
                onNewPhotoDelete: (photo) => _removeNewPhoto(_newPhotos.indexOf(photo)),
                onSetPrimary: (photo) => _setPrimaryPhoto(photo),
              ),
            ),

            // Removed photos section (if any)
            if (_photosToRemove.isNotEmpty) ...[
              const Divider(),
              Text(
                'Removed Photos (tap to restore)',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _photosToRemove.length,
                  itemBuilder: (context, index) {
                    final photo = _photosToRemove[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => _restorePhoto(photo),
                        child: Container(
                          width: 80,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.red, width: 2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.network(
                              photo.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => 
                                Container(
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.error),
                                ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onCancel,
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveChanges,
                    child: const Text('Save Changes'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

}
