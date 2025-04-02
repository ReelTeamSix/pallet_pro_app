import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pallet_pro_app/src/core/theme/app_icons.dart';
import 'package:pallet_pro_app/src/core/theme/theme_extensions.dart';
import 'package:pallet_pro_app/src/features/inventory/data/models/pallet.dart';
import 'package:pallet_pro_app/src/features/inventory/presentation/providers/pallet_field_values_provider.dart';
import 'package:pallet_pro_app/src/features/inventory/presentation/providers/pallet_list_provider.dart';
import 'package:pallet_pro_app/src/global/widgets/primary_button.dart';
import 'package:pallet_pro_app/src/global/widgets/styled_text_field.dart';

/// Screen for adding a new pallet or editing an existing one.
///
/// If [pallet] is null, the screen is in "add" mode.
/// If [pallet] is provided, the screen is in "edit" mode.
class AddEditPalletScreen extends ConsumerStatefulWidget {
  final Pallet? pallet;

  const AddEditPalletScreen({
    super.key,
    this.pallet,
  });

  @override
  ConsumerState<AddEditPalletScreen> createState() => _AddEditPalletScreenState();
}

class _AddEditPalletScreenState extends ConsumerState<AddEditPalletScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _supplierController = TextEditingController();
  final _sourceController = TextEditingController();
  final _typeController = TextEditingController();
  final _formatController = TextEditingController();
  final _costController = TextEditingController();
  final _dateController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  String? _errorMessage;
  
  // For dropdowns
  List<String> _supplierSuggestions = [];
  List<String> _sourceSuggestions = [];
  List<String> _formatSuggestions = [];

  @override
  void initState() {
    super.initState();
    
    // If editing an existing pallet, populate the form fields
    if (widget.pallet != null) {
      final pallet = widget.pallet!;
      _nameController.text = pallet.name;
      _supplierController.text = pallet.supplier ?? '';
      _sourceController.text = pallet.source ?? '';
      
      // Set a default type for display (hidden field)
      _typeController.text = pallet.type != null 
        ? capitalizeWords(pallet.type!) // Capitalize for display
        : 'Other'; // Default
      
      // Leave format empty for existing pallets
      _formatController.text = '';
      
      _costController.text = pallet.cost.toStringAsFixed(2);
      
      if (pallet.purchaseDate != null) {
        _selectedDate = pallet.purchaseDate!;
        _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
      } else {
        _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
      }
    } else {
      // Default date for new pallets
      _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
      
      // Default type (hidden from user)
      _typeController.text = 'other';
      
      // We'll set a default pallet name in didChangeDependencies after we have the context
    }
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Only set default name if this is a new pallet and the name is currently empty
    if (widget.pallet == null && _nameController.text.isEmpty) {
      // Set a default with current date while we load the number
      final now = DateTime.now();
      final dateStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      _nameController.text = "Pallet #1 - $dateStr";  // Start with #1 by default
      
      // Then try to load the actual next number
      _loadNextPalletNumber();
    }
  }
  
  // Load the next available pallet number for default naming
  Future<void> _loadNextPalletNumber() async {
    try {
      // Get the next number from the provider
      final nextNumberAsync = ref.read(nextPalletNumberProvider);
      
      nextNumberAsync.whenData((nextNumber) {
        if (mounted) {
          // Get the current date part from the existing name
          final existingName = _nameController.text;
          final datePartIndex = existingName.indexOf(" - ");
          final datePart = datePartIndex > 0 ? existingName.substring(datePartIndex) : "";
          
          // Replace just the number part
          setState(() {
            _nameController.text = "Pallet #$nextNumber$datePart";
          });
          
          // Debug
          print("Updated pallet name to: ${_nameController.text}");
        }
      });
    } catch (e) {
      print("Error loading next pallet number: $e");
      // Keep the default #1 if there's an error
    }
  }
  
  // Load suggestions for dropdowns
  void _loadSuggestions() {
    // Load supplier suggestions
    ref.read(palletSuppliersProvider).whenData((suppliers) {
      if (mounted) {
        setState(() {
          _supplierSuggestions = suppliers;
        });
      }
    });
    
    // Load source suggestions (retailers)
    ref.read(palletSourcesProvider).whenData((sources) {
      if (mounted) {
        setState(() {
          _sourceSuggestions = sources;
          
          // Add some common retailer suggestions if we don't have many
          if (_sourceSuggestions.length < 3) {
            _sourceSuggestions.addAll([
              "Amazon",
              "Walmart",
              "Target",
              "Dollar General"
            ].where((source) => !_sourceSuggestions.contains(source)));
          }
        });
      }
    });
    
    // Define format suggestions separately from sources
    setState(() {
      _formatSuggestions = [
        "Amazon Monster",
        "Amazon Medium",
        "Amazon High Piece Count",
        "Amazon LPN",
        "Target Returns",
        "Walmart Overstock",
        "Dollar General Mixed",
        "DHL",
        "Unclaimed Mail",
        "3PL"
      ];
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _supplierController.dispose();
    _sourceController.dispose();
    _typeController.dispose();
    _formatController.dispose();
    _costController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  // Show date picker and update the field
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
      });
    }
  }

  // Save the pallet (create new or update existing)
  Future<void> _savePallet() async {
    // Validate the form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Parse cost from the text field
      final double cost = double.parse(_costController.text);
      
      if (widget.pallet == null) {
        // Create a new pallet
        final newPallet = Pallet(
          id: '', // ID will be generated by the backend
          name: _nameController.text,
          cost: cost,
          supplier: _supplierController.text.isNotEmpty ? _supplierController.text : null,
          source: _sourceController.text.isNotEmpty ? _sourceController.text : null,
          // For database compatibility, always use one of the valid enum types
          // We already set this to 'other' by default in initState
          type: 'other', 
          purchaseDate: _selectedDate,
        );
        
        final result = await ref.read(palletListProvider.notifier).addPallet(newPallet);
        
        result.when(
          success: (pallet) {
            // Return to previous screen on success
            if (mounted) {
              context.pop(true); // Return true to indicate success
            }
          },
          failure: (exception) {
            setState(() {
              _errorMessage = 'Error creating pallet: ${exception.message}';
              _isLoading = false;
            });
          },
        );
      } else {
        // TODO: Phase 5.5 will implement updatePallet functionality
        setState(() {
          _errorMessage = 'Editing existing pallets will be implemented in Phase 5.5';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Unexpected error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.pallet != null;
    final title = isEditing ? 'Edit Pallet' : 'Add Pallet';
    
    // Load suggestions for dropdowns
    _loadSuggestions();
    
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(context.spacingMd),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Name field (required)
                StyledTextField(
                  controller: _nameController,
                  labelText: 'Pallet Name*',
                  hintText: 'E.g., Electronics Pallet #1',
                  helperText: 'A default name has been generated. Feel free to change it.',
                  prefixIcon: const Icon(AppIcons.inventory),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: context.spacingMd),
                
                // Supplier field (optional) with autocomplete
                Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return _supplierSuggestions;
                    }
                    return _supplierSuggestions.where((option) => 
                      option.toLowerCase().contains(textEditingValue.text.toLowerCase())
                    );
                  },
                  onSelected: (String selection) {
                    _supplierController.text = selection;
                  },
                  fieldViewBuilder: (
                    BuildContext context,
                    TextEditingController controller,
                    FocusNode focusNode,
                    VoidCallback onFieldSubmitted,
                  ) {
                    // Sync the autocomplete controller with our controller
                    controller.text = _supplierController.text;
                    controller.addListener(() {
                      _supplierController.text = controller.text;
                    });
                    
                    return StyledTextField(
                      controller: controller,
                      focusNode: focusNode,
                      labelText: 'Supplier',
                      hintText: 'E.g., GRPL, Amazon, Walmart',
                      helperText: 'The company you purchased the pallet from',
                      prefixIcon: const Icon(AppIcons.business),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (String value) {
                        onFieldSubmitted();
                      },
                    );
                  },
                ),
                SizedBox(height: context.spacingMd),
                
                // Pallet Format/Variety field (new)
                Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return _formatSuggestions;
                    }
                    return _formatSuggestions.where((option) => 
                      option.toLowerCase().contains(textEditingValue.text.toLowerCase())
                    );
                  },
                  onSelected: (String selection) {
                    _formatController.text = selection;
                  },
                  fieldViewBuilder: (
                    BuildContext context,
                    TextEditingController controller,
                    FocusNode focusNode,
                    VoidCallback onFieldSubmitted,
                  ) {
                    // Sync the autocomplete controller with our controller
                    controller.text = _formatController.text;
                    controller.addListener(() {
                      _formatController.text = controller.text;
                    });
                    
                    return StyledTextField(
                      controller: controller,
                      focusNode: focusNode,
                      labelText: 'Pallet Format/Type',
                      hintText: 'E.g., Amazon Monster, Target, DHL, High Piece Count',
                      helperText: 'The specific type or format of the pallet (as offered by supplier)',
                      prefixIcon: const Icon(AppIcons.category),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (String value) {
                        onFieldSubmitted();
                      },
                    );
                  },
                ),
                SizedBox(height: context.spacingMd),
                
                // Source field (optional but important) with autocomplete
                Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return _sourceSuggestions;
                    }
                    return _sourceSuggestions.where((option) => 
                      option.toLowerCase().contains(textEditingValue.text.toLowerCase())
                    );
                  },
                  onSelected: (String selection) {
                    _sourceController.text = selection;
                  },
                  fieldViewBuilder: (
                    BuildContext context,
                    TextEditingController controller,
                    FocusNode focusNode,
                    VoidCallback onFieldSubmitted,
                  ) {
                    // Sync the autocomplete controller with our controller
                    controller.text = _sourceController.text;
                    controller.addListener(() {
                      _sourceController.text = controller.text;
                    });
                    
                    return StyledTextField(
                      controller: controller,
                      focusNode: focusNode,
                      labelText: 'Retailer/Source',
                      hintText: 'E.g., Amazon, Walmart, Target, Dollar General',
                      helperText: 'The retailer where the merchandise originated from',
                      prefixIcon: const Icon(AppIcons.storefront),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (String value) {
                        onFieldSubmitted();
                      },
                    );
                  },
                ),
                SizedBox(height: context.spacingMd),
                
                // Cost field (required)
                StyledTextField(
                  controller: _costController,
                  labelText: 'Cost*',
                  hintText: 'E.g., 450.00',
                  prefixIcon: const Icon(AppIcons.money),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a cost';
                    }
                    try {
                      final cost = double.parse(value);
                      if (cost <= 0) {
                        return 'Cost must be greater than zero';
                      }
                    } catch (e) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: context.spacingMd),
                
                // Date field (required)
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: AbsorbPointer(
                    child: StyledTextField(
                      controller: _dateController,
                      labelText: 'Purchase Date*',
                      hintText: 'Select date',
                      prefixIcon: const Icon(AppIcons.calendar),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a date';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                SizedBox(height: context.spacingLg),
                
                // Error message
                if (_errorMessage != null)
                  Padding(
                    padding: EdgeInsets.only(bottom: context.spacingMd),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: context.errorColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                
                // Save button
                PrimaryButton(
                  text: isEditing ? 'Update Pallet' : 'Add Pallet',
                  onPressed: _isLoading ? null : _savePallet,
                  isLoading: _isLoading,
                ),
                
                // Cancel button
                SizedBox(height: context.spacingMd),
                TextButton(
                  onPressed: _isLoading ? null : () => context.pop(),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 