import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A reusable text form field widget with consistent styling.
class StyledTextField extends StatelessWidget {
  /// Creates a styled text field.
  ///
  /// The [controller] manages the text being edited.
  /// The [labelText] is displayed floating above the text field.
  /// The [hintText] is displayed inside the text field when it's empty.
  /// The [validator] is used for input validation.
  /// Other parameters customize the text field's appearance and behavior.
  const StyledTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.onChanged,
    this.onFieldSubmitted,
    this.focusNode,
    this.autofocus = false,
    this.enabled = true,
    this.inputFormatters,
    this.prefixIcon,
    this.suffixIcon,
    this.textAlign = TextAlign.start,
  });

  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool enabled;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.5)),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: theme.disabledColor.withOpacity(0.3)),
        ),
        filled: true,
        // Add fill color based on theme if desired
        // fillColor: theme.colorScheme.surfaceVariant,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        // Align label behavior consistently
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        counterText: "",
      ),
      validator: validator,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      focusNode: focusNode,
      autofocus: autofocus,
      enabled: enabled,
      inputFormatters: inputFormatters,
      textAlign: textAlign,
      // Consider adding style customization from theme
      // style: theme.textTheme.bodyLarge,
    );
  }
} 