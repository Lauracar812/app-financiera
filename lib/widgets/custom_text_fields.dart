import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Widgets de entrada de texto personalizados para la aplicación financiera
/// Incluye validación, formateo y estilos mejorados

/// Campo de texto personalizado con diseño mejorado
class CustomTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final bool obscureText;
  final bool enabled;
  final VoidCallback? onTap;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final String? prefixText;
  final TextStyle? textStyle;
  final bool readOnly;

  const CustomTextField({
    super.key,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    required this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.maxLines = 1,
    this.obscureText = false,
    this.enabled = true,
    this.onTap,
    this.borderColor,
    this.focusedBorderColor,
    this.prefixText,
    this.textStyle,
    this.readOnly = false,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _borderAnimation;
  late Animation<Color?> _colorAnimation;
  
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    
    _borderAnimation = Tween<double>(
      begin: 1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _colorAnimation = ColorTween(
      begin: widget.borderColor ?? const Color(0xFFE2E8F0),
      end: widget.focusedBorderColor ?? const Color(0xFF6366F1),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
      
      if (_isFocused) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: _isFocused
                    ? [
                        BoxShadow(
                          color: (widget.focusedBorderColor ?? const Color(0xFF6366F1))
                              .withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: TextFormField(
                controller: widget.controller,
                focusNode: _focusNode,
                validator: widget.validator,
                keyboardType: widget.keyboardType,
                inputFormatters: widget.inputFormatters,
                maxLines: widget.maxLines,
                obscureText: widget.obscureText,
                enabled: widget.enabled,
                onTap: widget.onTap,
                readOnly: widget.readOnly,
                style: widget.textStyle ?? const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1E293B),
                ),
                decoration: InputDecoration(
                  labelText: widget.label,
                  labelStyle: TextStyle(
                    color: _isFocused
                        ? (widget.focusedBorderColor ?? const Color(0xFF6366F1))
                        : const Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                  hintText: widget.hint,
                  hintStyle: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: widget.prefixIcon != null
                      ? Icon(
                          widget.prefixIcon,
                          color: _isFocused
                              ? (widget.focusedBorderColor ?? const Color(0xFF6366F1))
                              : const Color(0xFF64748B),
                        )
                      : null,
                  suffixIcon: widget.suffixIcon,
                  prefixText: widget.prefixText,
                  prefixStyle: const TextStyle(
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: widget.borderColor ?? const Color(0xFFE2E8F0),
                      width: 1.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: widget.borderColor ?? const Color(0xFFE2E8F0),
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _colorAnimation.value ?? const Color(0xFF6366F1),
                      width: _borderAnimation.value,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFFEF4444),
                      width: 1.5,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFFEF4444),
                      width: 2.0,
                    ),
                  ),
                  filled: true,
                  fillColor: _isFocused
                      ? Colors.white
                      : const Color(0xFFF8FAFC),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Campo de texto para cantidades monetarias
class CurrencyTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool enabled;
  final VoidCallback? onTap;

  const CurrencyTextField({
    super.key,
    required this.label,
    this.hint,
    required this.controller,
    this.validator,
    this.enabled = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      label: label,
      hint: hint ?? '0.00',
      prefixIcon: Icons.attach_money,
      prefixText: 'COP \$ ',
      controller: controller,
      validator: validator,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
        _CurrencyInputFormatter(),
      ],
      enabled: enabled,
      onTap: onTap,
      focusedBorderColor: const Color(0xFF10B981),
    );
  }
}

/// Campo de texto para búsqueda con animación
class SearchTextField extends StatefulWidget {
  final String hint;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;

  const SearchTextField({
    super.key,
    this.hint = 'Buscar...',
    required this.controller,
    this.onChanged,
    this.onClear,
  });

  @override
  State<SearchTextField> createState() => _SearchTextFieldState();
}

class _SearchTextFieldState extends State<SearchTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: widget.controller,
              onChanged: widget.onChanged,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Color(0xFF64748B),
                ),
                suffixIcon: widget.controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear,
                          color: Color(0xFF64748B),
                        ),
                        onPressed: () {
                          widget.controller.clear();
                          if (widget.onClear != null) {
                            widget.onClear!();
                          }
                          if (widget.onChanged != null) {
                            widget.onChanged!('');
                          }
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Campo de texto con etiquetas/chips
class TagTextField extends StatefulWidget {
  final String label;
  final String hint;
  final List<String> tags;
  final ValueChanged<List<String>> onTagsChanged;

  const TagTextField({
    super.key,
    required this.label,
    this.hint = 'Agregar etiqueta...',
    required this.tags,
    required this.onTagsChanged,
  });

  @override
  State<TagTextField> createState() => _TagTextFieldState();
}

class _TagTextFieldState extends State<TagTextField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addTag() {
    final tag = _controller.text.trim();
    if (tag.isNotEmpty && !widget.tags.contains(tag)) {
      final newTags = List<String>.from(widget.tags)..add(tag);
      widget.onTagsChanged(newTags);
      _controller.clear();
    }
  }

  void _removeTag(String tag) {
    final newTags = List<String>.from(widget.tags)..remove(tag);
    widget.onTagsChanged(newTags);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              // Campo de entrada
              TextField(
                controller: _controller,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle: const TextStyle(
                    color: Color(0xFF94A3B8),
                  ),
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addTag,
                  ),
                ),
                onSubmitted: (_) => _addTag(),
              ),
              // Etiquetas existentes
              if (widget.tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.tags.map((tag) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF6366F1).withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            tag,
                            style: const TextStyle(
                              color: Color(0xFF6366F1),
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () => _removeTag(tag),
                            child: const Icon(
                              Icons.close,
                              size: 14,
                              color: Color(0xFF6366F1),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Formateador personalizado para campos de moneda
class _CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String newText = newValue.text;
    
    // Remover caracteres no numéricos excepto punto decimal
    newText = newText.replaceAll(RegExp(r'[^\d.]'), '');
    
    // Asegurar que solo haya un punto decimal
    List<String> parts = newText.split('.');
    if (parts.length > 2) {
      newText = '${parts[0]}.${parts[1]}';
    }
    
    // Limitar a 2 decimales
    if (parts.length == 2 && parts[1].length > 2) {
      newText = '${parts[0]}.${parts[1].substring(0, 2)}';
    }
    
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}