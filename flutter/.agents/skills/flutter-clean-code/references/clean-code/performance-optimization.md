# Performance Optimization in Flutter

> Performance best practices for 60/120 FPS rendering and memory hygiene.

---

## 1. Widget Rebuild Hygiene

- **Use `const` constructors aggressively**: Every `const` widget subtree short-circuits the Flutter element diffing algorithm, completely avoiding rebuilds.
- **Extract Small, Focused Widgets**: Rebuilds are scoped to the widget's `build()` method. Splitting complex trees into separate private widgets prevents whole-screen rebuilding when a single label changes.
- **Use `RepaintBoundary`**: Wrap complex subtrees (e.g. charts, custom painters, frequent animations) in `RepaintBoundary` to isolate their painting layer.

---

## 2. List & Scroll Performance

- **Always use `.builder` constructors**: `ListView.builder` or `SliverList.builder` lazily build only the visible viewport items. Never pass a raw `children: [...]` list with many items.
- **Provide `itemExtent` or `prototypeItem`**: When list items have a fixed height, specify `itemExtent` so Flutter doesn't need to lay out every child to calculate scroll geometry.
- **`addAutomaticKeepAlives: false`**: For very long lists without internal text fields or video controllers, disabling keep-alives allows memory reclamation.

---

## 3. Memory & Controller Leaks

- **Mandatory Disposal**: Always dispose of resources in `State.dispose()` or use scoped manager lifecycles:
  - `TextEditingController`
  - `AnimationController`
  - `ScrollController`
  - `FocusNode`
  - `StreamSubscription`
- **Image Caching & Sizing**: Use `ResizeImage` or `cacheWidth`/`cacheHeight` on `Image.network` to avoid decoding 4K images into GPU memory when displayed in small 60x60 avatars.
