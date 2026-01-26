import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oman_tv/common/utils/app_screen_util.dart';
import 'package:oman_tv/configs/theme/app_colors.dart';
import 'package:oman_tv/configs/theme/app_theme.dart';

class InputTextStyle {
  static TextStyle inputStyle(BuildContext context) {
    return context.medium.copyWith(fontSize: 14, color: AppColors.black);
  }
}

mixin CustomDecorationMixin {
  InputDecoration customDecoration({
    required BuildContext context,
    String? hintText,
    Widget? suffixIcon,
    Widget? prefixIcon,
    double? radius = 30,
    IconButton? suffixIconButton,
    TextStyle? hintTextStyle,
    EdgeInsets? contentPadding,
    Color? borderColor,
    bool? hideBorder,
    Color? bgColor,
  }) {
    return InputDecoration(
      errorMaxLines: 2,
      contentPadding:
          contentPadding ??
          EdgeInsets.symmetric(
            horizontal: 16.widthMultiplier,
            vertical: 15.heightMultiplier,
          ),
      hintStyle:
          hintTextStyle ??
          context.regular.copyWith(color: AppColors.beige, fontSize: 14),
      border: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.primary),
        borderRadius: BorderRadius.circular(radius ?? 8),
      ),
      prefixIcon: prefixIcon == null
          ? null
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                prefixIcon,
                Container(
                  height: 24.heightMultiplier,
                  width: 1,
                  margin: EdgeInsets.symmetric(horizontal: 12.widthMultiplier),
                  color: AppColors.beige,
                ),
              ],
            ),
      suffixIcon: suffixIconButton ?? suffixIcon,
      errorStyle: context.regular.copyWith(color: AppColors.red, fontSize: 11),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius ?? 8),
        borderSide: BorderSide(
          width: 1,
          color: borderColor ?? AppColors.lightBeige,
        ),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius ?? 8),
        borderSide: BorderSide(
          width: 1,
          color: borderColor ?? AppColors.greyBorder,
        ),
      ),
      filled: true,
      fillColor: bgColor ?? AppColors.bg,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius ?? 8),
        borderSide: BorderSide(width: 1, color: AppColors.primary),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius ?? 8),
        borderSide: BorderSide(width: 1, color: AppColors.primary),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius ?? 8),
        borderSide: BorderSide(width: 1, color: AppColors.red),
      ),
      hintText: hintText,
    );
  }
}

class UniversalTextField extends StatelessWidget with CustomDecorationMixin {
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final Widget? prefixIcon;
  final bool? enabled;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final String? hintText;
  final TextStyle? hintTextStyle;
  final double? radius;
  final Color? borderColor;
  final Color? bgColor;
  final bool? hideBorder;
  final int? maxLines;
  final bool? enableFilled;
  final EdgeInsets? contentPadding;
  final TextStyle? textStyle;
  final bool? readOnly;
  final List<TextInputFormatter>? inputFormatters;
  final Function()? onTap;
  final Function(String)? onChanged;
  final AutovalidateMode? autovalidateMode;
  final FocusNode? focusNode;
  final TextCapitalization textCapitalization;
  final bool? obscureText;

  const UniversalTextField({
    super.key,
    required this.controller,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.enabled,
    this.hintText,
    this.hintTextStyle,
    this.radius = 30,
    this.borderColor,
    this.bgColor,
    this.hideBorder,
    this.maxLines,
    this.enableFilled,
    this.contentPadding,
    this.textStyle,
    this.readOnly,
    this.inputFormatters,
    this.onTap,
    this.autovalidateMode,
    this.focusNode,
    this.onChanged,
    this.textCapitalization = TextCapitalization.none,
    this.obscureText,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      textCapitalization: textCapitalization,
      enabled: enabled,
      readOnly: readOnly ?? false,
      obscureText: obscureText ?? false,
      obscuringCharacter: '●',
      onTap: onTap,
      style: textStyle ?? InputTextStyle.inputStyle(context),
      cursorErrorColor: AppColors.primary,
      autovalidateMode: autovalidateMode ?? AutovalidateMode.onUserInteraction,
      controller: controller,
      cursorColor: AppColors.primary,
      keyboardType: keyboardType,
      maxLines: maxLines ?? 1,
      inputFormatters: inputFormatters,
      focusNode: focusNode,
      onChanged: onChanged,
      decoration: customDecoration(
        hintText: hintText,
        hintTextStyle: hintTextStyle,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        bgColor: bgColor,
        context: context,
        borderColor: borderColor,
        hideBorder: hideBorder,
        radius: radius,
        contentPadding: contentPadding,
      ),
      validator: validator,
    );
  }
}

class PhoneTextField extends StatelessWidget with CustomDecorationMixin {
  final TextEditingController controller;
  final Widget? prefixIcon;
  final bool autofocus;
  final bool? enableFilled;
  final double? radius;
  final Color? borderColor;

  const PhoneTextField({
    super.key,
    required this.controller,
    this.prefixIcon,
    this.autofocus = false,
    this.enableFilled,
    this.radius,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autofocus: autofocus,
      controller: controller,
      keyboardType: TextInputType.phone,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      cursorColor: AppColors.primary,
      inputFormatters: [
        LengthLimitingTextInputFormatter(10),
        FilteringTextInputFormatter.deny(RegExp(r'\s')),
        FilteringTextInputFormatter.digitsOnly,
      ],
      decoration: customDecoration(
        hintText: 'Phone number',
        context: context,
        prefixIcon: prefixIcon,
      ),
      style: InputTextStyle.inputStyle(context),
    );
  }
}

class EmailTextField extends StatelessWidget with CustomDecorationMixin {
  final TextEditingController controller;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool? enabled;
  final String? hintText;
  final Color? bgColor;
  final Color? borderColor;

  const EmailTextField({
    super.key,
    required this.controller,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled,
    this.hintText,
    this.bgColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: enabled,
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      cursorColor: AppColors.primary,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: customDecoration(
        bgColor: bgColor,
        borderColor: borderColor,
        context: context,
        hintText: hintText ?? 'Enter Email',
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
      inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
      style: InputTextStyle.inputStyle(context),
    );
  }
}

class PasswordTextField extends StatelessWidget with CustomDecorationMixin {
  final TextEditingController controller;
  final String? hintText;
  final bool readOnly;
  final bool isObSecure;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final bool denySpaces;
  final TextStyle? style;
  final void Function(String)? onChanged;

  PasswordTextField({
    super.key,
    this.style,
    required this.controller,
    this.hintText,
    this.readOnly = false,
    this.suffixIcon,
    this.prefixIcon,
    this.isObSecure = true,
    this.denySpaces = true,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.visiblePassword,
      cursorColor: AppColors.primary,
      // validator: CustomValidtion.isPassword,
      readOnly: readOnly,
      onChanged: onChanged,
      obscureText: isObSecure,
      obscuringCharacter: '●',
      decoration: customDecoration(
        context: context,
        hintText: hintText ?? 'Enter your password',
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
      ),
      inputFormatters: [
        if (denySpaces) FilteringTextInputFormatter.deny(RegExp(r'\s')),
      ],
      style: InputTextStyle.inputStyle(context),
    );
  }
}
