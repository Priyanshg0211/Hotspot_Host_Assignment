import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:ui';
import '../constants/app_constants.dart';
import '../constants/app_spacing.dart';

/// Reusable text input field with consistent styling
class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final int maxLength;
  final bool isKeyboardOpen;
  final TextCapitalization textCapitalization;
  final TextInputAction textInputAction;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.maxLength,
    this.isKeyboardOpen = false,
    this.textCapitalization = TextCapitalization.sentences,
    this.textInputAction = TextInputAction.done,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final height = isKeyboardOpen
        ? AppSpacing.textFieldHeightKeyboard
        : AppSpacing.textFieldHeight;
    final fontSize = isKeyboardOpen ? 14.0 : 16.0;

    return Column(
      children: [
        Container(
          height: height,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(AppSpacing.cardRadiusSmall),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            maxLines: null,
            maxLength: maxLength,
            textCapitalization: textCapitalization,
            textInputAction: textInputAction,
            onSubmitted: (_) {
              // Auto-close keyboard on done
              FocusScope.of(context).unfocus();
            },
            style: AppConstants.smallRegular.copyWith(
              color: Colors.white,
              fontSize: fontSize,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: AppConstants.smallRegular.copyWith(
                color: Colors.white.withOpacity(0.3),
                fontSize: fontSize,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(20),
              counter: const SizedBox.shrink(),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.elementSmall),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '${controller.text.length}/$maxLength',
            style: AppConstants.lowercaseRegular.copyWith(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

/// Reusable next button with gradient styling
class NextButton extends StatefulWidget {
  final VoidCallback? onTap;
  final String text;
  final bool isEnabled;

  const NextButton({
    Key? key,
    required this.onTap,
    this.text = 'Next',
    this.isEnabled = true,
  }) : super(key: key);

  @override
  State<NextButton> createState() => _NextButtonState();
}

class _NextButtonState extends State<NextButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.isEnabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: widget.isEnabled ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.isEnabled ? widget.onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        height: AppSpacing.buttonHeight,
        transform: Matrix4.translationValues(0, _isPressed ? 2 : 0, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadiusSmall),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF101010),
              const Color(0xFF1A1A1A),
              const Color(0xFFFFFFFF).withOpacity(0.05),
            ],
            stops: const [0.0, 0.7, 1.0],
          ),
          boxShadow: _isPressed
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(1.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.cardRadiusSmall),
              gradient: const RadialGradient(
                center: Alignment(0.0, -0.8),
                radius: 1.5,
                colors: [Color(0xFF2A2A2A), Color(0xFF1A1A1A)],
                stops: [0.0, 1.0],
              ),
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.text,
                    style: AppConstants.smallRegular.copyWith(
                      fontFamily: 'Space Grotesk',
                      color: widget.isEnabled
                          ? Colors.white.withOpacity(0.9)
                          : Colors.white.withOpacity(0.3),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SvgPicture.asset(
                    'assets/icon/arrow.svg',
                    width: 15,
                    height: 15,
                    colorFilter: ColorFilter.mode(
                      widget.isEnabled
                          ? Colors.white.withOpacity(0.9)
                          : Colors.white.withOpacity(0.3),
                      BlendMode.srcIn,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Reusable top bar with progress indicator
class CustomTopBar extends StatelessWidget {
  final double progress;
  final VoidCallback? onBack; 
  final VoidCallback onClose;

  const CustomTopBar({
    Key? key,
    required this.progress,
    this.onBack, 
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.02)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                if (onBack != null)
                  GestureDetector(
                    onTap: onBack,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                if (onBack != null) const SizedBox(width: 16),
                Expanded(
                  child: SizedBox(
                    height: 8,
                    child: CustomPaint(
                      painter: WaveProgressPainter(
                        progress: progress,
                        activeColor: const Color(0xFF5B7FFF),
                        inactiveColor: Colors.white.withOpacity(0.2),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: onClose,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
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
}

/// Screen wrapper with consistent background and padding
class ScreenWrapper extends StatelessWidget {
  final Widget child;
  final double? bottomPadding;

  const ScreenWrapper({Key? key, required this.child, this.bottomPadding})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage('assets/images/background.png'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.3),
            BlendMode.darken,
          ),
        ),
      ),
      child: SafeArea(child: child),
    );
  }
}

/// Section title with step number
class SectionTitle extends StatelessWidget {
  final String stepNumber;
  final String title;
  final String? subtitle;
  final bool isKeyboardOpen;

  const SectionTitle({
    Key? key,
    required this.stepNumber,
    required this.title,
    this.subtitle,
    this.isKeyboardOpen = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final titleSize = isKeyboardOpen ? 18.0 : 24.0;
    final subtitleSize = isKeyboardOpen ? 12.0 : 16.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          stepNumber,
          style: AppConstants.smallRegular.copyWith(
            color: Colors.white.withOpacity(0.5),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          style: AppConstants.bodyBold.copyWith(
            color: Colors.white,
            fontSize: titleSize,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 10),
          Text(
            subtitle!,
            style: AppConstants.smallRegular.copyWith(
              color: Colors.white.withOpacity(0.4),
              fontSize: subtitleSize,
            ),
          ),
        ],
      ],
    );
  }
}

/// Wave progress painter for top bar
class WaveProgressPainter extends CustomPainter {
  final double progress;
  final Color activeColor;
  final Color inactiveColor;

  WaveProgressPainter({
    required this.progress,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    const waveLength = 16.0;
    const amplitude = 2.5;
    final centerY = size.height / 2;

    final path = Path();
    path.moveTo(0, centerY);

    double x = 0;
    while (x <= size.width) {
      final y = centerY + amplitude * (x / waveLength * 2 * 3.14159).sin();
      path.lineTo(x, y);
      x += 0.5;
    }

    paint.color = inactiveColor;
    canvas.drawPath(path, paint);

    if (progress > 0) {
      paint.color = activeColor;
      final progressWidth = size.width * progress;

      canvas.save();
      canvas.clipRect(Rect.fromLTWH(0, 0, progressWidth, size.height));
      canvas.drawPath(path, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(WaveProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.inactiveColor != inactiveColor;
  }
}

extension on double {
  double sin() {
    double x = this % (2 * 3.14159);
    if (x < 0) x += 2 * 3.14159;

    double result = x;
    double term = x;

    for (int i = 1; i <= 7; i++) {
      term *= -x * x / ((2 * i) * (2 * i + 1));
      result += term;
    }

    return result;
  }
}
