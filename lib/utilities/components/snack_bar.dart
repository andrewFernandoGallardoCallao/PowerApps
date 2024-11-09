import 'package:flutter/material.dart';

class AnimatedSnackBar extends StatefulWidget {
  final String message;

  const AnimatedSnackBar({Key? key, required this.message}) : super(key: key);
  
  @override
  _AnimatedSnackBarState createState() => _AnimatedSnackBarState();
}

class _AnimatedSnackBarState extends State<AnimatedSnackBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // Iniciar la animación cuando el widget se construya
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SnackBar(
      duration: Duration(seconds: 2),
      content: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return ScaleTransition(
            scale: _animation,
            child: Row(
              children: [
                Icon(Icons.check, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  widget.message,
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

void showAnimatedSnackBar(BuildContext context, String message) {
  final snackBar = SnackBar(
    duration: const Duration(seconds: 2),
    content: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Icon(Icons.check, color: Colors.white),
        const SizedBox(width: 8),
        Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
      ],
    ),
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.green,
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
