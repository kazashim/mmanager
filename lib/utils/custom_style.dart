import 'package:flutter/material.dart';
import 'package:mmanager/screens/intro_screen.dart';
import 'package:mmanager/utils/colors.dart';

class CustomStyle {
  static var textStyle = TextStyle(
      color: CustomColor.greyColor, fontSize: Dimensions.defaultTextSize);

  static var hintTextStyle = TextStyle(
      color: Colors.grey.withOpacity(0.5),
      fontSize: Dimensions.defaultTextSize);

  static var listStyle =
      TextStyle(color: Colors.white, fontSize: Dimensions.defaultTextSize);

  static var defaultStyle =
      TextStyle(color: Colors.black, fontSize: Dimensions.largeTextSize);

  static var focusBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(5.0)),
    borderSide: BorderSide(color: Colors.black.withOpacity(0.1), width: 2.0),
  );

  static var focusErrorBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(5.0)),
    borderSide: BorderSide(color: Colors.black.withOpacity(0.1), width: 1.0),
  );

  static var searchBox = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(10.0)),
    borderSide: BorderSide(color: Colors.black.withOpacity(0.1), width: 1.0),
  );
}
