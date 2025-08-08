import 'package:flutter/material.dart';
import '../constants/breakpoints.dart';

typedef ResponsiveBuilder =
    Widget Function(BuildContext context, BoxConstraints constraints);

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({super.key, required this.builder});

  final ResponsiveBuilder builder;

  static bool isXs(BuildContext context) =>
      MediaQuery.sizeOf(context).width < Breakpoints.sm;
  static bool isSm(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= Breakpoints.sm &&
      MediaQuery.sizeOf(context).width < Breakpoints.md;
  static bool isMd(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= Breakpoints.md &&
      MediaQuery.sizeOf(context).width < Breakpoints.lg;
  static bool isLg(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= Breakpoints.lg &&
      MediaQuery.sizeOf(context).width < Breakpoints.xl;
  static bool isXl(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= Breakpoints.xl;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => builder(context, constraints),
    );
  }
}
