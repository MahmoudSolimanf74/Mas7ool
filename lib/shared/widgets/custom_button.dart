import 'package:flutter/material.dart';

enum ButtonType { primary, secondary, destructive, outline }

class CustomButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final ButtonType type;
  final double? width;

  const CustomButton({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
    this.isLoading = false,
    this.type = ButtonType.primary,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    Color getBgColor() {
      switch (type) {
        case ButtonType.primary:
          return const Color(0xFF2563EB);
        case ButtonType.secondary:
          return const Color(0xFF334155);
        case ButtonType.destructive:
          return const Color(0xFFDC2626);
        case ButtonType.outline:
          return Colors.transparent;
      }
    }

    Color getFgColor() {
      switch (type) {
        case ButtonType.outline:
          return const Color(0xFF38BDF8);
        default:
          return Colors.white;
      }
    }

    BorderSide? getBorder() {
      if (type == ButtonType.outline) {
        return const BorderSide(color: Color(0xFF38BDF8), width: 1.5);
      }
      return null;
    }

    return SizedBox(
      width: width,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: getBgColor(),
          foregroundColor: getFgColor(),
          side: getBorder(),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
