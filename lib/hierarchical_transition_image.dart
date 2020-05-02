library hierarchical_transition_image;

import 'dart:math';

import 'package:flutter/material.dart';

const int CONTAINER_REVERSE_DURATION = 200;
const double VERTICAL_SWIPE_THRESHOLD = 150;
const double CONTAINER_MIN_OPACITY = 0.3;
const int TRANSITION_DURATION = 600;

mixin HierarchicalTransitionSource {
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
                        const Duration(milliseconds: TRANSITION_DURATION)));
              }),
        ),
      ),
    );
  }
}

abstract class HierarchicalTransitionImageStatefulWidget
    extends StatefulWidget {
  final String _tag;
  final String image;

  HierarchicalTransitionImageStatefulWidget(this._tag, this.image);
}

abstract class HierarchicalTransitionDestinationState<
    T extends HierarchicalTransitionImageStatefulWidget> extends State<T> {
  Offset _beginningDragPosition = Offset.zero;
  Offset _currentDragPosition = Offset.zero;
  int _containerReverseDuration = 0;

  Matrix4 get _containerVerticalTransform {
    final Matrix4 translationTransform = Matrix4.translationValues(
      0,
      _currentDragPosition.dy,
      0.0,
    );

    return translationTransform;
  }

  double get _containerBackgroundOpacity {
    return max(
        1.0 - _currentDragPosition.distance * 0.003, CONTAINER_MIN_OPACITY);
  }

  void _rebuild() {
    setState(() {});
  }

  Widget destinationContainer(Widget child) {
    return Container(
      color: Colors.black.withOpacity(_containerBackgroundOpacity),
      child: Listener(
        onPointerDown: _onPointerDown,
        onPointerMove: _onPointerMove,
        onPointerUp: _onPointerUp,
        child: AnimatedContainer(
          duration: Duration(milliseconds: _containerReverseDuration),
          transform: _containerVerticalTransform,
          child: Hero(
              tag: this.widget._tag,
              child: Material(
                color: Colors.transparent,
                child: child,
              )),
        ),
      ),
    );
  }

  void _onPointerDown(PointerDownEvent event) {
    _containerReverseDuration = 0;
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
    print(_currentDragPosition.distance);
    if (_currentDragPosition.distance < VERTICAL_SWIPE_THRESHOLD) {
      // Dragしてしきい値超えてなかったら元にもどす。
      _currentDragPosition = Offset.zero;
      _containerReverseDuration = CONTAINER_REVERSE_DURATION;
      _rebuild();
    } else {
      // しきい値超えたら、前の画面に戻る。
      Navigator.pop(context);
    }
  }
}
