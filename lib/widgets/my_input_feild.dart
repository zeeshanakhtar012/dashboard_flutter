import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class MyInputField extends StatefulWidget {
  final String? hint;
  final String? label;
  final bool? isPasswordField;
  final TextStyle? textStyle;
  final Function(String? value)? onChange;
  final TextInputType? keyboardType;
  final void Function(String)? onFieldSubmitted;
  final Widget? prefix;
  final int? limit;
  final double? height;
  final TextEditingController? controller;
  final VoidCallback? onTap;
  final bool? readOnly;
  final Color? fillColor;
  final int? maxLines;
  final int? minLines;
  final String? text;
  final Color? counterColor;
  final bool? showCounter;
  final bool? showBorder;
  final bool? isDense;
  final FocusNode? focusNode;
  final EdgeInsetsGeometry? margin;
  final String? Function(String?)? validator;
  final Future<String?> Function(String?)? asyncValidator;
  final Widget? suffix;
  final InputBorder? border;
  final InputBorder? enabledBorder;
  final BorderStyle? borderType;
  final EdgeInsetsGeometry? padding;

  MyInputField({
    this.hint,
    this.isPasswordField,
    this.onChange,
    this.padding,
    this.keyboardType,
    this.prefix,
    this.limit,
    this.height,
    this.controller,
    this.onTap,
    this.readOnly,
    this.fillColor,
    this.maxLines,
    this.text,
    this.showCounter,
    this.counterColor,
    this.showBorder,
    this.minLines,
    this.margin,
    this.suffix,
    this.validator,
    this.isDense,
    this.onFieldSubmitted,
    this.asyncValidator,
    this.label,
    this.textStyle,
    this.border,
    this.enabledBorder,
    this.borderType,
    this.focusNode,
  });

  final _state = _MyInputFieldState();

  @override
  _MyInputFieldState createState() => _state;

  Future<void> validate() async {
    if (asyncValidator != null) {
      await _state.validate();
    }
  }
}

class _MyInputFieldState extends State<MyInputField> {
  late TextEditingController _controller;
  late bool _isHidden;
  String text = "";
  bool isPasswordField = false;
  String? errorMessage;
  bool isValidating = false;
  bool isValid = false;
  bool isDirty = false;

  @override
  void initState() {
    super.initState();
    isPasswordField = widget.isPasswordField ?? false;
    _isHidden = isPasswordField;

    // Initialize controller if null
    _controller = widget.controller ?? TextEditingController();
    if (widget.text != null) {
      _controller.text = widget.text!;
    }

    // Check if both validators are set
    if (widget.validator != null && widget.asyncValidator != null) {
      throw "Validator and asyncValidator cannot be used at the same time.";
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 2),
      height: widget.height ?? 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        color: const Color(0xFF190733),
      ),
      child: TextFormField(
        controller: _controller,
        maxLength: widget.limit,
        onChanged: widget.asyncValidator == null ? widget.onChange : (value) {
          text = value.toString();
          validateValue(text);
          if (widget.onChange != null) {
            widget.onChange!(text);
          }
        },
        style: widget.textStyle,
        obscureText: _isHidden,
        onTap: widget.onTap,
        validator: widget.validator ?? (widget.asyncValidator != null
            ? (value) {
          text = value.toString();
          return errorMessage;
        }
            : null),
        maxLines: widget.maxLines ?? 1,
        minLines: widget.minLines,
        readOnly: widget.readOnly ?? false,
        keyboardType: widget.keyboardType,
        onFieldSubmitted: widget.onFieldSubmitted,
        focusNode: widget.focusNode,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(
          prefixIcon: widget.prefix,
          hintText: widget.hint,
          labelText: widget.label,
          isDense: widget.isDense,
          fillColor: widget.fillColor ?? const Color(0xff8A8D9F),
          filled: widget.fillColor != null,
          suffixIcon: widget.suffix ?? (isPasswordField ? IconButton(
            onPressed: () {
              setState(() {
                _isHidden = !_isHidden;
              });
            },
            icon: Icon(
              _isHidden ? Icons.visibility : Icons.visibility_off,
              color: Colors.grey,
            ),
          ) : null),
          contentPadding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          border: widget.border ?? InputBorder.none,
        ),
      ),
    );
  }

  Future<void> validateValue(String newValue) async {
    isDirty = true;
    if (text.isEmpty) {
      setState(() {
        isValid = false;
      });
      return;
    }
    isValidating = true;
    setState(() {});

    errorMessage = await widget.asyncValidator!(newValue);
    isValidating = false;
    isValid = errorMessage == null;
    setState(() {});
  }

  Future<void> validate() async {
    await validateValue(text);
  }
}
