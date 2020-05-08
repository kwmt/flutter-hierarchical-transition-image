import 'package:flutter/material.dart';
import 'package:hierarchical_transition_image/hierarchical_transition_image.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with HierarchicalTransitionSource {
  @override
  int get transitionDuration => 50;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          String image = "assets/gopher.png";
          String tag = "list$index";
          return sourceContainer<DetailPage>(
            context,
            tag,
            image,
            DetailPage(tag, image),
          );
        });
  }
}

class DetailPage extends HierarchicalTransitionImageStatefulWidget {
  DetailPage(String tag, String image) : super(tag, image);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState
    extends HierarchicalTransitionDestinationState<DetailPage> {
  @override
  double get verticalSwipeThreshold => 50;

  @override
  Widget build(BuildContext context) {
    return destinationContainer(
        Container(child: Image.asset(this.widget.image)));
  }
}
