import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quote_feature/quote_list.dart';
import 'package:quote_feature/quote_screen.dart';
import 'package:vyuh_core/vyuh_core.dart';


final feature = FeatureDescriptor(
  name: 'quote_feature',
  title: 'Quote Feature',
  description: 'Describe your feature in more detail here.',
  icon: Icons.add_circle_outlined,
  routes: () async {
    return [
      GoRoute(
        path: '/quote_screen',
        builder: (context, state) => const QuotePage(),
      ),
      GoRoute(
        path: '/quote_list',
        builder: (context, state) => const QuoteListPage(),
      ),
    ];
  },
);
