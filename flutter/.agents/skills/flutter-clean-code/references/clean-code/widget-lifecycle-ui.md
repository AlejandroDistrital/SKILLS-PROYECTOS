# Flutter Widget Architecture, Clean UI & Lifecycle Hygiene

> Source: [Flutter Widget Tree & Performance Best Practices](https://docs.flutter.dev/perf/best-practices)

---

## 1. The Core UI Rules

1. **One Main Widget Per File**: Keep files focused. If a file exceeds ~300 lines, extract internal sub-widgets.
2. **Zero Logic in Widgets**: No HTTP requests, SQL transactions, or complex sorting in `build()` or `initState()`.
3. **Always use `const` constructors**: Allows Flutter to skip rebuilding elements when ancestor state changes.

---

## 2. Widget Decomposition & Avoiding Deep Nesting

### Anti-Pattern: Monolithic Deep Nesting ("Pyramid of Doom")

```dart
// Bad: Huge build method with deeply nested indentation
class DashboardView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(...),
              child: Row(
                children: [
                  Icon(...),
                  Column(
                    children: [
                      Text(...),
                      Text(...),
                    ],
                  ),
                ],
              ),
            ),
            // ... 200 more lines of inline widgets ...
          ],
        ),
      ),
    );
  }
}
```

### Clean Pattern: Small Focused Widgets with `const`

Extract subtrees into dedicated `StatelessWidget` classes (either in the same file as `_PrivateWidget` if small, or in `features/<feature>/presentation/widgets/`):

```dart
// Clean: Clear composition and readable hierarchy
class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _UserSummaryHeader(),
              SizedBox(height: AppSpacing.lg),
              _MetricOverviewGrid(),
              SizedBox(height: AppSpacing.lg),
              Expanded(child: _RecentActivityList()),
            ],
          ),
        ),
      ),
    );
  }
}
```

> **Why Class Widgets over Helper Methods?**
> A helper method `Widget _buildHeader()` does not have its own `Element` and forces rebuilds of everything within the parent `build()`. A separate `StatelessWidget` class can be `const`, avoids unnecessary rebuilds, and integrates properly with the Flutter inspector.

---

## 3. Lifecycle Hygiene & Preventing Memory Leaks

Always dispose of every resource in `StatefulWidget.dispose()` or the state management controller's cleanup hook:

- `TextEditingController`
- `ScrollController`
- `AnimationController`
- `StreamSubscription`
- `FocusNode`

```dart
class _SearchInputState extends State<SearchInput> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
    );
  }
}
```
