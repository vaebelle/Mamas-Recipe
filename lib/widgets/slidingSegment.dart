import 'package:flutter/cupertino.dart';

class CustomSegmentedControl<T extends Object> extends StatelessWidget {
  final T groupValue;
  final ValueChanged<T?>? onValueChanged;
  final Map<T, Widget> children;
  final Color? backgroundColor;
  final Color? thumbColor;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? borderColor;
  final double borderWidth;

  const CustomSegmentedControl({
    super.key,
    required this.groupValue,
    required this.onValueChanged,
    required this.children,
    this.backgroundColor,
    this.thumbColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 20.0),
    this.borderRadius = 8.0,
    this.borderColor,
    this.borderWidth = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: borderColor != null && borderWidth > 0
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: borderColor!, width: borderWidth),
            )
          : null,
      child: CupertinoSlidingSegmentedControl<T>(
        backgroundColor: backgroundColor ?? CupertinoColors.white,
        thumbColor: thumbColor ?? CupertinoColors.white,
        groupValue: groupValue,
        onValueChanged: onValueChanged ?? (T? _) {},
        children: _buildPaddedChildren(),
      ),
    );
  }

  Map<T, Widget> _buildPaddedChildren() {
    return children.map((key, value) => MapEntry(
          key,
          Padding(
            padding: padding,
            child: value,
          ),
        ));
  }
}


enum Sky { midnight, viridian, cerulean }

Map<Sky, Color> skyColors = <Sky, Color>{
  Sky.midnight: const Color(0xff191970),
  Sky.viridian: const Color(0xff40826d),
  Sky.cerulean: const Color(0xff007ba7),
};

void main() => runApp(const SegmentedControlApp());

class SegmentedControlApp extends StatelessWidget {
  const SegmentedControlApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      theme: CupertinoThemeData(brightness: Brightness.light),
      home: SegmentedControlExample(),
    );
  }
}

class SegmentedControlExample extends StatefulWidget {
  const SegmentedControlExample({super.key});

  @override
  State<SegmentedControlExample> createState() => _SegmentedControlExampleState();
}

class _SegmentedControlExampleState extends State<SegmentedControlExample> {
  Sky _selectedSegment = Sky.midnight;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: skyColors[_selectedSegment],
      navigationBar: CupertinoNavigationBar(
        middle: CustomSegmentedControl<Sky>(
          groupValue: _selectedSegment,
          thumbColor: skyColors[_selectedSegment]!,
          onValueChanged: (Sky? value) {
            if (value != null) {
              setState(() {
                _selectedSegment = value;
              });
            }
          },
          children: const <Sky, Widget>{
            Sky.midnight: Text(
              'All Recipes',
              style: TextStyle(color: CupertinoColors.white),
            ),
            Sky.viridian: Text(
              'Favorites', 
              style: TextStyle(color: CupertinoColors.white),
            ),
            Sky.cerulean: Text(
              'My Recipes',
              style: TextStyle(color: CupertinoColors.white),
            ),
          },
        ),
      ),
      child: Center(
        child: Text(
          'Selected Segment: ${_selectedSegment.name}',
          style: const TextStyle(color: CupertinoColors.white),
        ),
      ),
    );
  }
}