import 'package:another_flushbar/flushbar.dart';
import 'package:another_flushbar/flushbar_route.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Utils {
  static double averageRating(List<int> rating) {
    double avg = 0.0;
    for (var i = 0; i < rating.length; i++) {
      avg = avg + rating[i];
    }
    return avg / rating.length.toDouble();
  }

  static fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  static toastMessage(String message) {
    Fluttertoast.showToast(msg: message);
  }

  static flushBarErrorMessage(String message, BuildContext context) {
    showFlushbar(
        context: context,
        flushbar: Flushbar(
          backgroundColor: Colors.red,
          titleColor: Colors.white,
          message: message,
          duration: const Duration(seconds: 3),
          forwardAnimationCurve: Curves.ease,
          reverseAnimationCurve: Curves.easeInOut,
          icon: const Icon(
            Icons.error,
            size: 28,
            color: Colors.white,
          ),
          positionOffset: 20,
        )..show(context));
  }
}
