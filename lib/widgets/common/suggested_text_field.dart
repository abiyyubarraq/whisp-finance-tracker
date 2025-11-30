import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../glass_container.dart';

/// A text field with autocomplete suggestions dropdown.
///
/// Features:
/// - TextFormField with autocomplete dropdown
/// - X clear button (visible only when text exists)
/// - Case-insensitive filtering of suggestions
/// - Calls [onNewItemDetected] when typed text doesn't match any suggestion
/// - GlassContainer styling
/// - Custom suggestion rendering support via [suggestionBuilder]
class SuggestedTextField extends StatefulWidget {
  final TextEditingController controller;
  final List<String> suggestions;
  final String hintText;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final Function(bool)? onNewItemDetected;
  final Widget Function(String suggestion)? suggestionBuilder;
  final bool isLoading;
  final FocusNode? focusNode;
  final bool enabled;

  const SuggestedTextField({
    super.key,
    required this.controller,
    required this.suggestions,
    required this.hintText,
    this.prefixIcon,
    this.validator,
    this.onChanged,
    this.onNewItemDetected,
    this.suggestionBuilder,
    this.isLoading = false,
    this.focusNode,
    this.enabled = true,
  });

  @override
  State<SuggestedTextField> createState() => _SuggestedTextFieldState();
}

class _SuggestedTextFieldState extends State<SuggestedTextField> {
  late FocusNode _focusNode;
  List<String> _filteredSuggestions = [];
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
    widget.controller.addListener(_onTextChange);
    _filteredSuggestions = widget.suggestions;
  }

  @override
  void dispose() {
    // Remove listeners first to prevent any callbacks during disposal
    _focusNode.removeListener(_onFocusChange);
    widget.controller.removeListener(_onTextChange);

    // Remove overlay entry
    _removeOverlay();

    // Dispose focus node if we created it
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }

    super.dispose();
  }

  @override
  void didUpdateWidget(SuggestedTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Use listEquals to compare contents, not object references
    if (!listEquals(oldWidget.suggestions, widget.suggestions)) {
      _filterSuggestions();
    }
  }

  void _onFocusChange() {
    // Defer all operations to after the current frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (_focusNode.hasFocus) {
        _filterSuggestions();
        _showOverlay();
      } else {
        _removeOverlay();
      }
    });
  }

  void _onTextChange() {
    final query = widget.controller.text.toLowerCase().trim();

    // Update filtered suggestions synchronously for immediate use
    final newFilteredSuggestions = query.isEmpty
        ? widget.suggestions
        : widget.suggestions
              .where((s) => s.toLowerCase().contains(query))
              .toList();

    _checkIfNewItem();
    widget.onChanged?.call(widget.controller.text);

    // Defer state updates and overlay operations to after the current frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      setState(() {
        _filteredSuggestions = newFilteredSuggestions;
      });

      if (_focusNode.hasFocus && _filteredSuggestions.isNotEmpty) {
        _showOverlay();
      } else {
        _removeOverlay();
      }
    });
  }

  void _filterSuggestions() {
    final query = widget.controller.text.toLowerCase().trim();

    // Defer setState to after current frame to prevent build phase errors
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      setState(() {
        if (query.isEmpty) {
          _filteredSuggestions = widget.suggestions;
        } else {
          _filteredSuggestions = widget.suggestions
              .where((s) => s.toLowerCase().contains(query))
              .toList();
        }
      });

      // Update overlay if shown
      if (_overlayEntry != null) {
        _overlayEntry!.markNeedsBuild();
      }
    });
  }

  void _checkIfNewItem() {
    if (widget.onNewItemDetected == null) return;

    final text = widget.controller.text.trim();
    if (text.isEmpty) {
      widget.onNewItemDetected!(false);
      return;
    }

    // Check if text matches any suggestion (case-insensitive)
    final matches = widget.suggestions.any(
      (s) => s.toLowerCase() == text.toLowerCase(),
    );

    widget.onNewItemDetected!(!matches);
  }

  void _selectSuggestion(String suggestion) {
    // Store the suggestion locally since overlay will be removed
    final selectedValue = suggestion;

    // Temporarily remove the listener to prevent interference
    widget.controller.removeListener(_onTextChange);

    // Set the text FIRST before any other operations
    widget.controller.text = selectedValue;
    widget.controller.selection = TextSelection.fromPosition(
      TextPosition(offset: selectedValue.length),
    );

    // Re-add the listener
    widget.controller.addListener(_onTextChange);

    // Remove overlay after text is set
    _removeOverlay();

    // Defer focus change and callbacks to next frame to avoid rebuild interference
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _focusNode.unfocus();
      widget.onNewItemDetected?.call(false);
      widget.onChanged?.call(selectedValue);
    });
  }

  void _clearText() {
    // Defer all operations to after the current frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      widget.controller.clear();
      widget.onNewItemDetected?.call(false);
      widget.onChanged?.call('');
      _focusNode.requestFocus();
    });
  }

  void _showOverlay() {
    if (!mounted) return;

    _removeOverlay();

    if (_filteredSuggestions.isEmpty) return;

    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry?.dispose();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 4),
          child: Material(
            color: Colors.transparent,
            child: _buildSuggestionsDropdown(),
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionsDropdown() {
    if (_filteredSuggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxHeight = MediaQuery.of(context).size.height * 0.3;
    final itemHeight = 48.0;
    final suggestionsHeight = (_filteredSuggestions.length * itemHeight).clamp(
      0.0,
      maxHeight,
    );

    return GlassContainer(
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(12),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: suggestionsHeight),
        child: ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          itemCount: _filteredSuggestions.length,
          itemBuilder: (context, index) {
            final suggestion = _filteredSuggestions[index];

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (_) {
                _selectSuggestion(suggestion);
              },
              child: Container(
                height: itemHeight,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.centerLeft,
                child:
                    widget.suggestionBuilder?.call(suggestion) ??
                    Text(
                      suggestion,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasText = widget.controller.text.isNotEmpty;

    return CompositedTransformTarget(
      link: _layerLink,
      child: GlassContainer(
        padding: EdgeInsets.zero,
        child: TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          enabled: widget.enabled && !widget.isLoading,
          validator: widget.validator,
          style: TextStyle(
            fontSize: 15,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: TextStyle(
              fontSize: 14,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            prefixIcon: widget.prefixIcon != null
                ? Icon(
                    widget.prefixIcon,
                    size: 20,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  )
                : null,
            suffixIcon: widget.isLoading
                ? Padding(
                    padding: const EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  )
                : hasText
                ? IconButton(
                    icon: Icon(
                      Icons.clear_rounded,
                      size: 20,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    onPressed: _clearText,
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
        ),
      ),
    );
  }
}
