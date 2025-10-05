import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pallet_pro_app/src/core/exceptions/app_exceptions.dart';
import 'package:pallet_pro_app/src/core/utils/result.dart';
import 'package:pallet_pro_app/src/features/inventory/data/models/item.dart';
import 'package:pallet_pro_app/src/features/inventory/data/providers/inventory_repository_providers.dart';
import 'package:pallet_pro_app/src/features/inventory/presentation/providers/item_detail_provider.dart';
import 'package:pallet_pro_app/src/features/inventory/presentation/providers/item_list_provider.dart';
import 'package:pallet_pro_app/src/features/inventory/presentation/providers/pallet_list_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:image/image.dart' as img;
import 'package:pallet_pro_app/src/features/inventory/presentation/widgets/image_picker_grid.dart';
import 'package:pallet_pro_app/src/features/inventory/presentation/widgets/sales_channel_dropdown.dart';
import 'package:pallet_pro_app/src/global/utils/display_utils.dart';
import 'package:go_router/go_router.dart';

/// A screen for adding a new item or editing an existing one.
///
/// The screen includes fields for all item properties including storage location
/// and sales channel, plus image upload capabilities.
class AddEditItemScreen extends ConsumerStatefulWidget {
  /// For editing, null for new item
  final Item? item;
  
  /// For adding items directly to a pallet
  final String? palletId;
  
  const AddEditItemScreen({
    this.item,
    this.palletId,
    Key? key,
  }) : super(key: key);
  
  @override
  ConsumerState<AddEditItemScreen> createState() => _AddEditItemScreenState();
}

class _AddEditItemScreenState extends ConsumerState<AddEditItemScreen> {
  // Maximum photos allowed per item (free tier limitation)
  static const int _maxPhotosPerItem = 3;
  
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _quantityController;
  late final TextEditingController _storageLocationController;
  
  ItemCondition _selectedCondition = ItemCondition.newItem;
  
  // List of selected image files
  final List<XFile> _selectedImages = [];
  
  // List of image paths for existing item (if editing)
  final List<String> _existingImagePaths = [];
  
  // List of image paths that should be deleted (if editing)
  final List<String> _imagesToDelete = [];
  
  bool _isSubmitting = false;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize controllers with values from item if editing
    _nameController = TextEditingController(text: widget.item?.name);
    _descriptionController = TextEditingController(text: widget.item?.description ?? '');
    _quantityController = TextEditingController(text: widget.item?.quantity.toString() ?? '1');
    _storageLocationController = TextEditingController(
      text: widget.item?.storageLocation ?? '',
    );
    
    if (widget.item != null) {
      _selectedCondition = widget.item!.condition;
      
      // Load existing photos when editing
      _loadExistingPhotos();
    }
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    _storageLocationController.dispose();
    super.dispose();
  }
  
  // Check if there are unsaved changes
  bool _hasUnsavedChanges() {
    // If we're creating a new item, check if any fields have been filled
    if (widget.item == null) {
      return _nameController.text.isNotEmpty ||
             _descriptionController.text.isNotEmpty ||
             _quantityController.text != '1' ||
             _storageLocationController.text.isNotEmpty ||
             _selectedCondition != ItemCondition.newItem ||
             _selectedImages.isNotEmpty;
    }
    
    // If we're editing, check if any fields have changed
    return _nameController.text != widget.item!.name ||
           _descriptionController.text != (widget.item!.description ?? '') ||
           _quantityController.text != widget.item!.quantity.toString() ||
           _storageLocationController.text != (widget.item!.storageLocation ?? '') ||
           _selectedCondition != widget.item!.condition ||
           _selectedImages.isNotEmpty ||
           _imagesToDelete.isNotEmpty;
  }
  
  // Handle back button or close button
  Future<void> _onClose() async {
    if (!_hasUnsavedChanges()) {
      // Use context.pop() for consistency with the rest of the navigation
      context.pop(false);
      return;
    }
    
    // Show confirmation dialog
    final shouldDiscard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('You have unsaved changes that will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('DISCARD'),
          ),
        ],
      ),
    );
    
    if (shouldDiscard == true && mounted) {
      context.pop(false);
    }
  }
  
  Future<void> _pickImages() async {
    // Check if we've reached the photo limit
    final totalCurrentPhotos = _selectedImages.length + _existingImagePaths.length;
    final remainingSlots = _maxPhotosPerItem - totalCurrentPhotos;
    
    if (remainingSlots <= 0) {
      _showErrorSnackBar('Maximum of $_maxPhotosPerItem photos allowed per item');
      return;
    }
    
    final picker = ImagePicker();
    final selectedImages = await picker.pickMultiImage();
    
    if (selectedImages.isNotEmpty) {
      // Only add up to the remaining slots
      final imagesToAdd = selectedImages.length <= remainingSlots 
          ? selectedImages 
          : selectedImages.sublist(0, remainingSlots);
      
      setState(() {
        _selectedImages.addAll(imagesToAdd);
      });
      
      // Show warning if some images were not added due to limit
      if (selectedImages.length > remainingSlots) {
        _showErrorSnackBar('Only added $remainingSlots of ${selectedImages.length} selected images (limit: $_maxPhotosPerItem)');
      }
    }
  }
  
  Future<void> _takePicture() async {
    // Check if we've reached the photo limit
    final totalCurrentPhotos = _selectedImages.length + _existingImagePaths.length;
    if (totalCurrentPhotos >= _maxPhotosPerItem) {
      _showErrorSnackBar('Maximum of $_maxPhotosPerItem photos allowed per item');
      return;
    }
    
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    
    if (image != null) {
      setState(() {
        _selectedImages.add(image);
      });
    }
  }
  
  Future<XFile> _compressImage(XFile file) async {
    // Get temp directory
    final dir = await getTemporaryDirectory();
    final targetPath = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}_compressed.jpg';
    
    // Read file as bytes
    final bytes = await file.readAsBytes();
    
    // Compress image
    final result = await FlutterImageCompress.compressWithList(
      bytes,
      minHeight: 720, // Reduced from 1080px to 720px for better storage optimization
      minWidth: 720,
      quality: 85, // Adjust quality as needed (higher = better quality, larger size)
    );
    
    // Write compressed bytes to a new file
    final compressedFile = File(targetPath);
    await compressedFile.writeAsBytes(result);
    
    // Return the compressed file as XFile
    return XFile(compressedFile.path);
  }
  
  Future<List<XFile>> _compressSelectedImages() async {
    final List<XFile> compressedImages = [];
    
    for (final image in _selectedImages) {
      final compressedImage = await _compressImage(image);
      compressedImages.add(compressedImage);
    }
    
    return compressedImages;
  }
  
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }
  
  void _markExistingImageForDeletion(int index) {
    setState(() {
      _imagesToDelete.add(_existingImagePaths[index]);
      _existingImagePaths.removeAt(index);
    });
  }

  /// Load existing photos for editing
  Future<void> _loadExistingPhotos() async {
    if (widget.item == null) return;
    
    try {
      final photosResult = await ref.read(itemPhotoRepositoryProvider).getItemPhotos(widget.item!.id);
      if (photosResult.isSuccess && mounted) {
        setState(() {
          _existingImagePaths.clear();
          _existingImagePaths.addAll(photosResult.value!.map((photo) => photo.imageUrl));
        });
      }
    } catch (e) {
      print('Error loading existing photos: $e');
    }
  }
  
  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
  
  /// Save the item and handle results through GoRouter
  Future<void> _saveItem() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });
      
      try {
        final quantity = int.tryParse(_quantityController.text) ?? 1;
        
        // Creating a new item
        if (widget.item == null) {
          // Prepare the new item data
          final newItem = Item(
            id: const Uuid().v4(), // Generate a new UUID
            palletId: widget.palletId ?? '',
            name: _nameController.text,
            description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
            quantity: quantity,
            condition: _selectedCondition,
            status: ItemStatus.inStock,
            storageLocation: _storageLocationController.text.isNotEmpty ? _storageLocationController.text : null,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          
          // Create the new item
          final result = await ref.read(itemRepositoryProvider).createItem(newItem);
          
          if (result.isSuccess) {
            final createdItem = result.value!;
            
            // Upload images if any were selected
            if (_selectedImages.isNotEmpty) {
              await _uploadImagesForItem(createdItem.id);
            }
            
            // Force refresh of the item list
            ref.invalidate(itemListProvider);
            
            if (mounted) {
              context.pop(true);
            }
          } else {
            _showErrorSnackBar('Failed to add item: ${result.error?.message ?? "Unknown error"}');
            // Ensure we're not stuck in submitting state
            if (mounted) {
              setState(() {
                _isSubmitting = false;
              });
            }
          }
        } else {
          // Editing an existing item
          final updatedItem = widget.item!.copyWith(
            name: _nameController.text,
            description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
            quantity: quantity,
            condition: _selectedCondition,
            storageLocation: _storageLocationController.text.isNotEmpty ? _storageLocationController.text : null,
            updatedAt: DateTime.now(),
          );
          
          final result = await ref.read(itemRepositoryProvider).updateItem(updatedItem);
          
          if (result.isSuccess) {
            // Handle image changes for existing item
            await _handleImageChangesForExistingItem(widget.item!.id);
            
            // Force refresh of both providers
            ref.invalidate(itemListProvider);
            ref.invalidate(itemDetailProvider(widget.item!.id));
            
            if (mounted) {
              context.pop(true);
            }
          } else {
            _showErrorSnackBar('Failed to update item: ${result.error?.message ?? "Unknown error"}');
            // Ensure we're not stuck in submitting state
            if (mounted) {
              setState(() {
                _isSubmitting = false;
              });
            }
          }
        }
      } catch (e) {
        _showErrorSnackBar('Error: $e');
        // Ensure we're not stuck in submitting state
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }
  
  /// Upload images for a newly created item
  Future<void> _uploadImagesForItem(String itemId) async {
    if (_selectedImages.isEmpty) return;
    
    try {
      // Compress images before upload
      final compressedImages = await _compressSelectedImages();
      
      // Upload each image
      for (int i = 0; i < compressedImages.length; i++) {
        final image = compressedImages[i];
        final fileName = '${itemId}_${i + 1}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        
        // Upload to storage
        final storagePath = await ref.read(storageRepositoryProvider).uploadItemPhoto(
          itemId: itemId,
          fileName: fileName,
          file: image,
        );
        
        // Save photo metadata to database
        await ref.read(itemPhotoRepositoryProvider).saveItemPhoto(
          itemId: itemId,
          storagePath: storagePath,
          isPrimary: i == 0, // First image is primary
        );
      }
    } catch (e) {
      print('Error uploading images: $e');
      _showErrorSnackBar('Failed to upload some images: $e');
    }
  }
  
  /// Handle image changes for an existing item (add new, delete existing)
  Future<void> _handleImageChangesForExistingItem(String itemId) async {
    try {
      // Delete images marked for deletion
      if (_imagesToDelete.isNotEmpty) {
        await ref.read(storageRepositoryProvider).deleteItemPhotos(_imagesToDelete);
        
        // Also delete from database (this should be handled by cascade delete or manually)
        // For now, we'll rely on the storage deletion
      }
      
      // Upload new images
      if (_selectedImages.isNotEmpty) {
        await _uploadImagesForItem(itemId);
      }
    } catch (e) {
      print('Error handling image changes: $e');
      _showErrorSnackBar('Failed to update some images: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // Create providers to access data
    final isEditing = widget.item != null;
    final itemDetailAsync = isEditing 
        ? ref.watch(itemDetailProvider(widget.item!.id)) 
        : const AsyncValue.data(null);
    
    // Calculate remaining photo capacity
    final int remainingPhotos = _maxPhotosPerItem - (_selectedImages.length + _existingImagePaths.length - _imagesToDelete.length);
    
    return PopScope(
      canPop: !_hasUnsavedChanges(),
      onPopInvoked: (didPop) async {
        // If we were able to pop normally, just return
        if (didPop) {
          return;
        }
        
        // Show confirmation dialog
        final shouldDiscard = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Discard changes?'),
            content: const Text('You have unsaved changes that will be lost.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('CANCEL'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('DISCARD'),
              ),
            ],
          ),
        );
        
        // Only pop if the user confirmed
        if (shouldDiscard == true && mounted) {
          if (context.mounted) {
            // Use context.pop() instead of GoRouter.of(context).pop()
            // This better integrates with the GoRouter navigation system
            context.pop();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEditing ? 'Edit Item' : 'Add New Item'),
          actions: [
            TextButton(
              onPressed: _isSubmitting ? null : _saveItem,
              child: Text(_isSubmitting ? 'Saving...' : 'Save'),
            ),
          ],
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Item details card
                Card(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Text(
                            'Basic Information',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        // Item name
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Item Name *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.inventory),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter an item name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16.0),
                        
                        // Item description
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Description (Optional)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.description),
                          ),
                          minLines: 2,
                          maxLines: 4,
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Inventory details card
                Card(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Text(
                            'Inventory Details',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        
                        // Quantity and Condition fields in separate columns to prevent overflow
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Quantity field
                            TextFormField(
                              controller: _quantityController,
                              decoration: const InputDecoration(
                                labelText: 'Quantity *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.numbers),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a quantity';
                                }
                                final qty = int.tryParse(value);
                                if (qty == null || qty < 1) {
                                  return 'Quantity must be at least 1';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16.0),
                            
                            // Condition dropdown with improved readability
                            DropdownButtonFormField<ItemCondition>(
                              value: _selectedCondition,
                              isExpanded: true, // Ensure dropdown doesn't overflow
                              decoration: const InputDecoration(
                                labelText: 'Condition *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.grade),
                              ),
                              items: ItemCondition.values.map((condition) {
                                // Format the condition value for better readability
                                return DropdownMenuItem<ItemCondition>(
                                  value: condition,
                                  child: Text(_formatCondition(condition)),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _selectedCondition = newValue;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16.0),
                        
                        // Storage location
                        TextFormField(
                          controller: _storageLocationController,
                          decoration: const InputDecoration(
                            labelText: 'Storage Location (Optional)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.location_on),
                            hintText: 'e.g., Shelf A2, Bin 5, Garage',
                          ),
                        ),
                        
                        // Sales channel dropdown (only shown if editing)
                        if (isEditing) const SizedBox(height: 16.0),
                        if (isEditing)
                          itemDetailAsync.when(
                            loading: () => const Center(child: CircularProgressIndicator()),
                            error: (_, __) => const Text('Failed to load item details'),
                            data: (item) => SalesChannelDropdown(
                              value: item?.salesChannel,
                              onChanged: (salesChannel) {
                                // Will be handled during save
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                
                // Photos card
                Card(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Item Photos',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '$remainingPhotos of $_maxPhotosPerItem available',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: remainingPhotos > 0 
                                    ? Theme.of(context).colorScheme.secondary 
                                    : Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12.0),
                        
                        // Image picker grid
                        ImagePickerGrid(
                          selectedImages: _selectedImages,
                          existingImageUrls: _existingImagePaths,
                          onPickImages: _pickImages,
                          onTakePhoto: _takePicture,
                          onRemoveImage: _removeImage,
                          onRemoveExistingImage: _markExistingImageForDeletion,
                          maxPhotos: _maxPhotosPerItem,
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Action buttons
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: SafeArea(
                    child: Column(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _isSubmitting ? null : _saveItem,
                          icon: _isSubmitting 
                              ? const SizedBox(
                                  width: 20, 
                                  height: 20, 
                                  child: CircularProgressIndicator(strokeWidth: 2.0)
                                )
                              : const Icon(Icons.save),
                          label: Text(_isSubmitting ? 'Saving...' : 'Save Item'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Theme.of(context).colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            minimumSize: const Size(double.infinity, 50),
                          ),
                        ),
                        const SizedBox(height: 12.0),
                        OutlinedButton.icon(
                          onPressed: _onClose,
                          icon: const Icon(Icons.cancel),
                          label: const Text('Cancel'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            minimumSize: const Size(double.infinity, 50),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  // Format condition values for display
  String _formatCondition(ItemCondition condition) {
    switch (condition) {
      case ItemCondition.newItem:
        return 'New Item';
      case ItemCondition.openBox:
        return 'Open Box';
      case ItemCondition.usedGood:
        return 'Used - Good';
      case ItemCondition.usedFair:
        return 'Used - Fair';
      case ItemCondition.damaged:
        return 'Damaged';
      case ItemCondition.forParts:
        return 'For Parts';
      default:
        return condition.toString().split('.').last;
    }
  }
} 