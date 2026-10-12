import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Field berlabel dengan ikon prefix opsional dan toggle mata untuk
/// password, sesuai halaman Login/Registrasi dan Profil di Figma.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.trailingLabel,
    this.hint,
    this.controller,
    this.initialValue,
    this.prefixIcon,
    this.obscureText = false,
    this.readOnly = false,
    this.keyboardType,
    this.errorText,
    this.onChanged,
    this.fillColor,
    this.textStyle,
    this.borderRadius,
  });

  final String label;
  final String? trailingLabel;
  final String? hint;
  final TextEditingController? controller;
  final String? initialValue;
  final IconData? prefixIcon;
  final bool obscureText;
  final bool readOnly;
  final TextInputType? keyboardType;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final Color? fillColor;
  final TextStyle? textStyle;
  final double? borderRadius;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscure = false;
  late TextEditingController _effectiveController;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
    _effectiveController = widget.controller ??
        TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(covariant AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller == null &&
        oldWidget.initialValue != widget.initialValue &&
        widget.initialValue != null) {
      _effectiveController.text = widget.initialValue!;
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _effectiveController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.trailingLabel != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.label, style: AppTextStyles.label),
              Text(
                widget.trailingLabel!,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textMutedSlate,
                  fontSize: 12,
                ),
              ),
            ],
          )
        else
          Text(widget.label, style: AppTextStyles.label),
        const SizedBox(height: 8),
        TextField(
          controller: _effectiveController,
          readOnly: widget.readOnly,
          obscureText: _obscure,
          keyboardType: widget.keyboardType,
          onChanged: widget.onChanged,
          style: widget.textStyle ?? AppTextStyles.body,
          decoration: InputDecoration(
            hintText: widget.hint,
            fillColor: widget.fillColor ?? AppColors.inputFill,
            filled: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius ?? 12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius ?? 12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius ?? 12),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon,
                    size: 20, color: AppColors.textSecondary)
                : null,
            suffixIcon: widget.obscureText
                ? IconButton(
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  )
                : null,
            errorText: widget.errorText,
          ),
        ),
      ],
    );
  }
}
