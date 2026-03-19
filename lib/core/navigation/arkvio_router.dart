import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ArkvioRouter {
  static final navigatorKey = GlobalKey<NavigatorState>();

  static void navigateToDocument(int documentId) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      GoRouter.of(context).push('/document/$documentId');
    }
  }
}
