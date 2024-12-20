import 'package:flutter/material.dart';

/// Entry point of the application
void main() {
  runApp(const MyApp());
}

/// Main application widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  /// Builds the widget tree for the application
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Dock(
            items: const [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
          ),
        ),
      ),
    );
  }
}

/// A customizable Dock widget that allows reordering of items
class Dock<T> extends StatefulWidget {
  /// List of items to display in the dock
  const Dock({
    super.key,
    this.items = const [],
  });

  final List<T> items;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

/// State class for the [Dock] widget
class _DockState<T> extends State<Dock<T>> {
  late List<T> _items; // Internal list of items in the dock
  int? _draggingIndex; // Index of the item currently being dragged
  double _dragOffsetY = 0; // Vertical offset during dragging

  /// Initializes the internal state of the widget
  @override
  void initState() {
    super.initState();
    _items = List.from(widget.items);
  }

  /// Builds an individual item in the dock
  Widget _buildItem(T item, int index) {
    final isDragging = _draggingIndex == index;

    return Container(
      key: ValueKey(item),
      child: Transform.translate(
        offset: Offset(0, isDragging ? _dragOffsetY : 0),
        child: Opacity(
          opacity: isDragging ? 0.7 : 1.0,
          child: Container(
            width: 60,
            height: 60,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.primaries[item.hashCode % Colors.primaries.length],
            ),
            child: Center(
              child: Icon(
                item as IconData,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Handles reordering of items in the dock
  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _items.removeAt(oldIndex);
      _items.insert(newIndex, item);
    });
  }

  /// Builds the dock widget
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black12,
      ),
      padding: const EdgeInsets.all(8),
      child: SizedBox(
        height: 76, // 60 for container height + 16 for padding
        child: ReorderableListView(
          scrollDirection: Axis.horizontal,
          buildDefaultDragHandles: false,
          onReorderStart: (index) {
            setState(() {
              _draggingIndex = index;
              _dragOffsetY = 0;
            });
          },
          onReorderEnd: (index) {
            setState(() {
              _draggingIndex = null;
              _dragOffsetY = 0;
            });
          },
          onReorder: _onReorder,
          proxyDecorator: (child, index, animation) {
            return AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                return Material(
                  color: Colors.transparent,
                  child: child,
                );
              },
              child: child,
            );
          },
          children: [
            for (int index = 0; index < _items.length; index++)
              Listener(
                key: ValueKey(_items[index]),
                onPointerMove: (event) {
                  setState(() {
                    _dragOffsetY += event.delta.dy;
                  });
                },
                child: ReorderableDragStartListener(
                  index: index,
                  child: _buildItem(_items[index], index),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
