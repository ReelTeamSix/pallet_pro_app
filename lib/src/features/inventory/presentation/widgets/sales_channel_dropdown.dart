import 'package:flutter/material.dart';

/// A reusable dropdown widget for selecting sales channels
class SalesChannelDropdown extends StatelessWidget {
  final String? value;
  final Function(String?) onChanged;
  final bool isRequired;
  final String label;
  
  const SalesChannelDropdown({
    Key? key,
    this.value,
    required this.onChanged,
    this.isRequired = false,
    this.label = 'Sales Channel',
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: isRequired ? '$label*' : label,
        border: const OutlineInputBorder(),
      ),
      value: value,
      onChanged: onChanged,
      items: _getSalesChannelItems(),
      validator: isRequired ? _requiredValidator : null,
    );
  }
  
  List<DropdownMenuItem<String>> _getSalesChannelItems() {
    return const [
      DropdownMenuItem(
        value: 'Facebook Marketplace',
        child: Text('Facebook Marketplace'),
      ),
      DropdownMenuItem(
        value: 'Facebook Group',
        child: Text('Facebook Group'),
      ),
      DropdownMenuItem(
        value: 'eBay',
        child: Text('eBay'),
      ),
      DropdownMenuItem(
        value: 'Amazon',
        child: Text('Amazon'),
      ),
      DropdownMenuItem(
        value: 'Mercari',
        child: Text('Mercari'),
      ),
      DropdownMenuItem(
        value: 'Etsy',
        child: Text('Etsy'),
      ),
      DropdownMenuItem(
        value: 'Poshmark',
        child: Text('Poshmark'),
      ),
      DropdownMenuItem(
        value: 'OfferUp',
        child: Text('OfferUp'),
      ),
      DropdownMenuItem(
        value: 'Craigslist',
        child: Text('Craigslist'),
      ),
      DropdownMenuItem(
        value: 'Yard Sale',
        child: Text('Yard Sale'),
      ),
      DropdownMenuItem(
        value: 'Local Pickup',
        child: Text('Local Pickup'),
      ),
      DropdownMenuItem(
        value: 'Other',
        child: Text('Other'),
      ),
    ];
  }
  
  String? _requiredValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select a sales channel';
    }
    return null;
  }
}

/// A provider for getting sales channel options
class SalesChannelOptions {
  static List<String> getAll() {
    return [
      'Facebook Marketplace',
      'Facebook Group',
      'eBay',
      'Amazon',
      'Mercari',
      'Etsy',
      'Poshmark',
      'OfferUp',
      'Craigslist',
      'Yard Sale',
      'Local Pickup',
      'Other',
    ];
  }
  
  static List<String> getPopular() {
    return [
      'Facebook Marketplace',
      'Facebook Group',
      'eBay',
      'Amazon',
      'Local Pickup',
    ];
  }
} 