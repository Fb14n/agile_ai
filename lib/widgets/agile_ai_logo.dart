import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// AgileAI Logo Widget - verwendbar als Icon, Ladeindikator oder Branding
class AgileAILogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool animated;

  const AgileAILogo({
    super.key,
    this.size = 64,
    this.showText = false,
    this.animated = false,
  });

  @override
  Widget build(BuildContext context) {
    final logo = SvgPicture.asset(
      'assets/logo/logo_simple.svg',
      width: size,
      height: size,
    );

    Widget result = animated
        ? _AnimatedLogo(size: size, child: logo)
        : logo;

    if (showText) {
      result = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          result,
          const SizedBox(height: 8),
          Text(
            'AgileAI',
            style: TextStyle(
              fontSize: size * 0.3,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF009688),
            ),
          ),
        ],
      );
    }

    return result;
  }
}

/// Animiertes Logo für Ladebildschirme
class _AnimatedLogo extends StatefulWidget {
  final double size;
  final Widget child;

  const _AnimatedLogo({required this.size, required this.child});

  @override
  State<_AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<_AnimatedLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 2 * 3.14159,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Loading-Widget mit Logo statt CircularProgressIndicator
class AgileAILoadingIndicator extends StatefulWidget {
  final double size;
  final String? message;

  const AgileAILoadingIndicator({
    super.key,
    this.size = 48,
    this.message,
  });

  @override
  State<AgileAILoadingIndicator> createState() => _AgileAILoadingIndicatorState();
}

class _AgileAILoadingIndicatorState extends State<AgileAILoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Transform.rotate(
                angle: _rotationAnimation.value * 2 * 3.14159,
                child: child,
              ),
            );
          },
          child: _buildLogoIcon(),
        ),
        if (widget.message != null) ...[
          const SizedBox(height: 16),
          Text(
            widget.message!,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLogoIcon() {
    // Custom painted logo for loading (no SVG dependency during animation)
    return CustomPaint(
      size: Size(widget.size, widget.size),
      painter: _LogoPainter(),
    );
  }
}

/// Custom Painter für das Logo (performanter als SVG für Animationen)
class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF00BCD4), Color(0xFF009688)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.42;

    // Sprint Circle (dashed)
    final circlePath = Path()
      ..addArc(
        Rect.fromCircle(center: center, radius: radius),
        -0.8,
        4.5,
      );
    canvas.drawPath(circlePath, paint);

    // Stylized "A"
    final aPath = Path()
      ..moveTo(size.width * 0.5, size.height * 0.22)
      ..lineTo(size.width * 0.28, size.height * 0.75)
      ..moveTo(size.width * 0.5, size.height * 0.22)
      ..lineTo(size.width * 0.72, size.height * 0.75)
      ..moveTo(size.width * 0.35, size.height * 0.55)
      ..lineTo(size.width * 0.65, size.height * 0.55);

    canvas.drawPath(aPath, paint);

    // AI Dot
    final dotPaint = Paint()
      ..color = const Color(0xFF00BCD4)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.22),
      size.width * 0.06,
      dotPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Splash Screen Widget
class AgileAISplash extends StatelessWidget {
  const AgileAISplash({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF009688),
              Color(0xFF00695C),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const AgileAILoadingIndicator(size: 80),
              ),
              const SizedBox(height: 32),
              // App Name
              const Text(
                'AgileAI',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your Intelligent Scrum Master',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
