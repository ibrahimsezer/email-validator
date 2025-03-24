// This is a GlobalKey Of Type Navigator State, Which Provides Same Key to Entire Widget Tree

import 'package:flutter/widgets.dart';

double getScreenWidth(BuildContext context) {
  return MediaQuery.of(context).size.width;
}

double getScreenHeight(BuildContext context) {
  return MediaQuery.of(context).size.height;
}
