library hierarchical_transition_image;

import 'dart:math';

import 'package:flutter/material.dart';

mixin HierarchicalTransitionSource {
  /// Duration time to transition animation (unit: milliseconds)
  int get transitionDuration => 600;

  /// Need to use page route widget
  Widget sourceContainer<T>(
      BuildContext context, String tag, String image, Widget child) {
    return Container(
      color: Colors.transparent,
      child: Hero(
        tag: tag,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
              child: Container(
                padding: EdgeInsets.all(16.0),
                child: Image.asset(
                  image,
                  fit: BoxFit.contain,
                ),
              ),
              onTap: () {
                Navigator.of(context).push(PageRouteBuilder<T>(
                    opaque: false,
                    fullscreenDialog: true,
                    pageBuilder: (context, animation, secondaryAnimation) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    transitionDuration:
                        Duration(milliseconds: transitionDuration)));
              }),
        ),
      ),
    );
  }
}

abstract class HierarchicalTransitionImageStatefulWidget
    extends StatefulWidget {
  final String _tag;

  /// Image path string
  final String image;

  HierarchicalTransitionImageStatefulWidget(this._tag, this.image);
}

abstract class HierarchicalTransitionDestinationState<
    T extends HierarchicalTransitionImageStatefulWidget> extends State<T> {
  /// A value that background min opacity
  double get backgroundMinOpacity => 0.3;

  /// A value that reverse duration
  int get reverseDuration => 200;

  /// A value that swipe vertical move distance threshold
  double get verticalSwipeThreshold => 150;

  /// Need to use a widget in your destination screen
  Widget destinationContainer(Widget child) {
    return Container(
      color: Colors.black.withOpacity(_backgroundOpacity),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: AnimatedContainer(
            duration: Duration(milliseconds: _reverseDuration),
            transform: _verticalCloseButtonTransform,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.close),
              color: Colors.white.withOpacity(_backgroundCloseButtonOpacity),
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: true,
          child: Center(
            child: Listener(
              onPointerDown: _onPointerDown,
              onPointerMove: _onPointerMove,
              onPointerUp: _onPointerUp,
              child: AnimatedContainer(
                color: Colors.transparent,
                duration: Duration(milliseconds: _reverseDuration),
                transform: _verticalTransform,
                child: Hero(
                    tag: this.widget._tag,
                    child: Material(
                      color: Colors.transparent,
                      child: child,
                    )),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// private bellow

  Offset _beginningDragPosition = Offset.zero;
  Offset _currentDragPosition = Offset.zero;
  int _reverseDuration = 0;

  Matrix4 get _verticalTransform {
    final Matrix4 translationTransform = Matrix4.translationValues(
      0,
      _currentDragPosition.dy,
      0.0,
    );

    return translationTransform;
  }

  double get _backgroundOpacity {
    return max(
        1.0 - _currentDragPosition.distance * 0.003, backgroundMinOpacity);
  }

  /// For close button transform
  Matrix4 get _verticalCloseButtonTransform {
    final Matrix4 translationTransform = Matrix4.translationValues(
      0,
      min(_currentDragPosition.dy, -_currentDragPosition.dy),
      0.0,
    );

    return translationTransform;
  }

  /// For close button opacity
  double get _backgroundCloseButtonOpacity {
    return max(
        1.0 - _currentDragPosition.distance * 0.03, backgroundMinOpacity);
  }

  void _rebuild() {
    setState(() {});
  }

  void _onPointerDown(PointerDownEvent event) {
    _reverseDuration = 0;
    _beginningDragPosition = event.position;
    _rebuild();
  }

  void _onPointerMove(PointerMoveEvent details) {
    _currentDragPosition = Offset(
      0,
      details.position.dy - _beginningDragPosition.dy,
    );
    _rebuild();
  }

  void _onPointerUp(PointerUpEvent event) {
    if (_currentDragPosition.distance < verticalSwipeThreshold) {
      // Dragしてしきい値超えてなかったら元にもどす。
      _currentDragPosition = Offset.zero;
      _reverseDuration = reverseDuration;
      _rebuild();
    } else {
      // しきい値超えたら、前の画面に戻る。
      Navigator.pop(context);
    }
  }
}
