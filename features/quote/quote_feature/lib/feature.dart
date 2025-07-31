import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vyuh_core/vyuh_core.dart';
import 'package:quote_feature/quote_screen.dart';
// import 'package:flutter_mobx/flutter_mobx.dart';
// import 'package:mobx/mobx.dart';

final feature = FeatureDescriptor(
  name: 'quote_feature',
  title: 'Quote Feature',
  description: 'Describe your feature in more detail here.',
  icon: Icons.add_circle_outlined,
  routes: () async {
    return [
      GoRoute(
          path: '/quote_screen',
          builder: (context, state) {
            return const QuoteScreen(
              quoteText:
                  "The fastest way to become the person you want to is to surround yourself with people who give you no choice but to become them",
              quoteDate: "31-07-2025",
              backgroundGradient: [Colors.deepPurple, Colors.indigo],
            );
          }),
    ];
  },
);
