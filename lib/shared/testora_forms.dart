import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';

// =============================================================================
// FORM LABEL
// =============================================================================

class TestoraFormLabel extends StatelessWidget {
  final String label;
  final bool isRequired;
  final Widget? trailing;

  const TestoraFormLabel({
    super.key,
    required this.label,
    this.isRequired = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text.rich(
            TextSpan(
              text: label,
              style: TextStyle(
                color: tokens.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.1,
              ),
              children: [
                if (isRequired)
                  TextSpan(
                    text: ' *',
                    style: TextStyle(
                      color: tokens.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

// =============================================================================
// TEXT FIELD
// =============================================================================

class TestoraTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final IconData? prefixIcon;
  final Widget? prefix;
  final Widget? suffix;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final int maxLines;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final FocusNode? focusNode;

  const TestoraTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.prefix,
    this.suffix,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.maxLines = 1,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final field = TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      enabled: enabled,
      readOnly: readOnly,
      autofocus: autofocus,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      inputFormatters: inputFormatters,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      onTap: onTap,
      style: TextStyle(
        color: enabled ? tokens.textPrimary : tokens.disabled,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      cursorColor: tokens.textPrimary,
      decoration: InputDecoration(
        hintText: hint,
        helperText: helperText,
        errorText: errorText,
        prefixIcon:
            prefix ??
            (prefixIcon != null
                ? Icon(
                  prefixIcon,
                  size: 20,
                  color: enabled ? tokens.textSecondary : tokens.disabled,
                )
                : null),
        suffixIcon: suffix,
        filled: true,
        fillColor:
            enabled
                ? (isDark ? tokens.surfaceSecondary : tokens.surfaceSecondary)
                : (isDark ? tokens.surface : const Color(0xFFF3F4F6)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: 15,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          borderSide: BorderSide(color: tokens.border, width: 1),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          borderSide: BorderSide(color: tokens.border.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          borderSide: BorderSide(color: tokens.textPrimary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          borderSide: BorderSide(color: tokens.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          borderSide: BorderSide(color: tokens.error, width: 1.5),
        ),
      ),
    );

    if (label == null) return field;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [TestoraFormLabel(label: label!), field],
    );
  }
}

// =============================================================================
// PASSWORD FIELD
// =============================================================================

class TestoraPasswordField extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final bool enabled;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;

  const TestoraPasswordField({
    super.key,
    this.controller,
    this.label,
    this.hint = 'Enter password',
    this.helperText,
    this.errorText,
    this.enabled = true,
    this.textInputAction,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
  });

  @override
  State<TestoraPasswordField> createState() => _TestoraPasswordFieldState();
}

class _TestoraPasswordFieldState extends State<TestoraPasswordField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return TestoraTextField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      label: widget.label,
      hint: widget.hint,
      helperText: widget.helperText,
      errorText: widget.errorText,
      obscureText: _obscured,
      enabled: widget.enabled,
      prefixIcon: Icons.lock_outline_rounded,
      textInputAction: widget.textInputAction,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      suffix: IconButton(
        icon: Icon(
          _obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          size: 20,
          color: tokens.textSecondary,
        ),
        tooltip: _obscured ? 'Show password' : 'Hide password',
        onPressed:
            widget.enabled
                ? () => setState(() => _obscured = !_obscured)
                : null,
      ),
    );
  }
}

// =============================================================================
// SEARCH FIELD
// =============================================================================

class TestoraSearchField extends StatefulWidget {
  final TextEditingController? controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final FocusNode? focusNode;

  const TestoraSearchField({
    super.key,
    this.controller,
    this.hint = 'Search subjects, exams, topics...',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.focusNode,
  });

  @override
  State<TestoraSearchField> createState() => _TestoraSearchFieldState();
}

class _TestoraSearchFieldState extends State<TestoraSearchField> {
  late final TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _hasText = _controller.text.isNotEmpty;
    _controller.addListener(_handleTextChanged);
  }

  void _handleTextChanged() {
    final has = _controller.text.isNotEmpty;
    if (has != _hasText) {
      setState(() => _hasText = has);
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_handleTextChanged);
    }
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    widget.onChanged?.call('');
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return TestoraTextField(
      controller: _controller,
      focusNode: widget.focusNode,
      hint: widget.hint,
      prefixIcon: Icons.search_rounded,
      textInputAction: TextInputAction.search,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      suffix:
          _hasText
              ? IconButton(
                icon: Icon(
                  Icons.cancel_rounded,
                  size: 18,
                  color: tokens.textMuted,
                ),
                tooltip: 'Clear search',
                onPressed: _clear,
              )
              : null,
    );
  }
}

// =============================================================================
// CHECKBOX
// =============================================================================

class TestoraCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Widget? label;
  final String? labelText;

  const TestoraCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.labelText,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final box = InkWell(
      onTap: onChanged != null ? () => onChanged!(!value) : null,
      borderRadius: BorderRadius.circular(6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color:
              value
                  ? tokens.textPrimary
                  : (isDark ? tokens.surfaceSecondary : Colors.transparent),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: value ? tokens.textPrimary : tokens.cardBorder,
            width: 1.5,
          ),
        ),
        child:
            value
                ? Icon(
                  Icons.check_rounded,
                  size: 16,
                  color:
                      isDark
                          ? AppColors.onPrimaryDark
                          : AppColors.onPrimaryLight,
                )
                : null,
      ),
    );

    if (label == null && labelText == null) return box;

    return InkWell(
      onTap: onChanged != null ? () => onChanged!(!value) : null,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            box,
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child:
                  label ??
                  Text(
                    labelText!,
                    style: TextStyle(
                      color: tokens.textPrimary,
                      fontSize: 13,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// VALIDATION MESSAGE
// =============================================================================

class TestoraValidationMessage extends StatelessWidget {
  final String message;
  final bool isError;

  const TestoraValidationMessage({
    super.key,
    required this.message,
    this.isError = true,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final color = isError ? tokens.error : tokens.success;

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Icon(
            isError
                ? Icons.error_outline_rounded
                : Icons.check_circle_outline_rounded,
            size: 15,
            color: color,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
