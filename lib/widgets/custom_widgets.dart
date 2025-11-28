import 'package:flutter/material.dart';

/// Widgets personalizados para mejorar la interfaz de usuario
/// Incluye cards, botones y elementos visuales con animaciones

/// Card personalizada con animaciones y sombras mejoradas
class CustomCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final double borderRadius;
  final bool showShadow;
  final VoidCallback? onTap;
  final bool isSelected;
  final Color? selectedColor;

  const CustomCard({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.borderRadius = 16,
    this.showShadow = true,
    this.onTap,
    this.isSelected = false,
    this.selectedColor,
  });

  @override
  State<CustomCard> createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _elevationAnimation = Tween<double>(
      begin: widget.showShadow ? 4.0 : 0.0,
      end: widget.showShadow ? 8.0 : 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap != null ? (_) => _onTapDown() : null,
      onTapUp: widget.onTap != null ? (_) => _onTapUp() : null,
      onTapCancel: widget.onTap != null ? _onTapCancel : null,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: widget.padding ?? const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: widget.isSelected
                    ? (widget.selectedColor ?? const Color(0xFF6366F1).withOpacity(0.1))
                    : (widget.backgroundColor ?? Colors.white),
                borderRadius: BorderRadius.circular(widget.borderRadius),
                border: widget.isSelected
                    ? Border.all(
                        color: widget.selectedColor ?? const Color(0xFF6366F1),
                        width: 2,
                      )
                    : Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                boxShadow: widget.showShadow
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: _elevationAnimation.value,
                          offset: Offset(0, _elevationAnimation.value / 2),
                        ),
                      ]
                    : null,
              ),
              child: widget.child,
            ),
          );
        },
      ),
    );
  }

  void _onTapDown() {
    setState(() {
      _isPressed = true;
    });
    _animationController.forward();
  }

  void _onTapUp() {
    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();
  }

  void _onTapCancel() {
    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();
  }
}

/// Botón personalizado con gradientes y animaciones
class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final bool isLoading;
  final bool isOutlined;
  final List<Color>? gradientColors;
  final double elevation;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.borderRadius = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    this.isLoading = false,
    this.isOutlined = false,
    this.gradientColors,
    this.elevation = 2,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    return GestureDetector(
      onTapDown: isEnabled ? (_) => _animationController.forward() : null,
      onTapUp: isEnabled ? (_) => _animationController.reverse() : null,
      onTapCancel: isEnabled ? () => _animationController.reverse() : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                gradient: widget.gradientColors != null && !widget.isOutlined
                    ? LinearGradient(colors: widget.gradientColors!)
                    : null,
                color: widget.isOutlined
                    ? Colors.transparent
                    : (widget.gradientColors == null
                        ? (widget.backgroundColor ?? const Color(0xFF6366F1))
                        : null),
                borderRadius: BorderRadius.circular(widget.borderRadius),
                border: widget.isOutlined
                    ? Border.all(
                        color: widget.backgroundColor ?? const Color(0xFF6366F1),
                        width: 2,
                      )
                    : null,
                boxShadow: !widget.isOutlined && widget.elevation > 0
                    ? [
                        BoxShadow(
                          color: (widget.backgroundColor ?? const Color(0xFF6366F1))
                              .withOpacity(0.3),
                          blurRadius: widget.elevation * 2,
                          offset: Offset(0, widget.elevation),
                        ),
                      ]
                    : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  onTap: isEnabled ? widget.onPressed : null,
                  child: Padding(
                    padding: widget.padding,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.isLoading)
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                widget.isOutlined
                                    ? (widget.backgroundColor ?? const Color(0xFF6366F1))
                                    : (widget.textColor ?? Colors.white),
                              ),
                            ),
                          )
                        else if (widget.icon != null) ...[
                          Icon(
                            widget.icon,
                            color: widget.isOutlined
                                ? (widget.backgroundColor ?? const Color(0xFF6366F1))
                                : (widget.textColor ?? Colors.white),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                        ],
                        if (!widget.isLoading)
                          Text(
                            widget.text,
                            style: TextStyle(
                              color: widget.isOutlined
                                  ? (widget.backgroundColor ?? const Color(0xFF6366F1))
                                  : (widget.textColor ?? Colors.white),
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Widget de estadística animada
class AnimatedStatCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String subtitle;
  final VoidCallback? onTap;

  const AnimatedStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.subtitle,
    this.onTap,
  });

  @override
  State<AnimatedStatCard> createState() => _AnimatedStatCardState();
}

class _AnimatedStatCardState extends State<AnimatedStatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _controller.forward();
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
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: CustomCard(
            onTap: widget.onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Transform.rotate(
                      angle: _rotationAnimation.value * 6.28,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: widget.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          widget.icon,
                          color: widget.color,
                          size: 24,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.trending_up,
                      color: widget.color,
                      size: 16,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: widget.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Indicador de progreso circular personalizado
class CustomProgressIndicator extends StatefulWidget {
  final double value;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;
  final double size;
  final String? centerText;

  const CustomProgressIndicator({
    super.key,
    required this.value,
    required this.color,
    this.backgroundColor = const Color(0xFFE2E8F0),
    this.strokeWidth = 8,
    this.size = 80,
    this.centerText,
  });

  @override
  State<CustomProgressIndicator> createState() => _CustomProgressIndicatorState();
}

class _CustomProgressIndicatorState extends State<CustomProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0,
      end: widget.value,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Stack(
            children: [
              CircularProgressIndicator(
                value: 1.0,
                strokeWidth: widget.strokeWidth,
                backgroundColor: widget.backgroundColor,
                valueColor: AlwaysStoppedAnimation<Color>(widget.backgroundColor),
              ),
              CircularProgressIndicator(
                value: _animation.value,
                strokeWidth: widget.strokeWidth,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(widget.color),
              ),
              if (widget.centerText != null)
                Positioned.fill(
                  child: Center(
                    child: Text(
                      widget.centerText!,
                      style: TextStyle(
                        fontSize: widget.size * 0.15,
                        fontWeight: FontWeight.w700,
                        color: widget.color,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Widget de navegación con pestañas personalizadas
class CustomTabBar extends StatelessWidget {
  final List<CustomTab> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const CustomTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          final isSelected = index == selectedIndex;

          return Expanded(
            child: GestureDetector(
              onTap: () => onTabSelected(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      tab.icon,
                      size: 18,
                      color: isSelected
                          ? const Color(0xFF6366F1)
                          : const Color(0xFF64748B),
                    ),
                    if (isSelected) ...[
                      const SizedBox(width: 8),
                      Text(
                        tab.text,
                        style: const TextStyle(
                          color: Color(0xFF6366F1),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class CustomTab {
  final String text;
  final IconData icon;

  const CustomTab({
    required this.text,
    required this.icon,
  });
}