import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hierarchical_transition_image/hierarchical_transition_image.dart';

void main() {
  testWidgets(
      'The widget HierarchicalTransitionImageStatefulWidget is Exteneded has a close icon',
      (WidgetTester tester) async {
    await tester.pumpWidget(
        buildTestableWidget(TestWidget("tag", "assets/gopher.png")));
    expect(find.byIcon(Icons.close), findsOneWidget);
  });
}

class TestWidget extends HierarchicalTransitionImageStatefulWidget {
  TestWidget(String tag, String image) : super(tag, image);

  @override
  State<StatefulWidget> createState() => _TestState();
}

class _TestState extends HierarchicalTransitionDestinationState {
  @override
  Widget build(BuildContext context) {
    return destinationContainer(
        Container(child: Image.asset(this.widget.image)));
  }
}

// https://stackoverflow.com/a/55696172
Widget buildTestableWidget(Widget widget) {
  return MediaQuery(data: MediaQueryData(), child: MaterialApp(home: widget));
}
