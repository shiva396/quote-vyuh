import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quote_feature/quote_list.dart';
import 'package:quote_feature/utils/home_screen_widget_utils.dart';
import 'package:quote_feature/utils/quote_share_utils.dart';

// Pale gradient combinations for better text readability

class QuotePage extends StatefulWidget {
  const QuotePage({super.key});

  @override
  State<QuotePage> createState() => _QuotePageState();
}

class _QuotePageState extends State<QuotePage> {
  final List<List<Color>> _gradients = [
    // Carefully selected pale gradients for optimal white text readability
    [const Color(0xFF232526), const Color(0xFF414345)], // Dark gray to charcoal
    [
      const Color(0xFF0F2027),
      const Color(0xFF2C5364)
    ], // Deep blue-black to navy
    [const Color(0xFF1A2980), const Color(0xFF26D0CE)], // Indigo to teal
    [
      const Color(0xFF373B44),
      const Color(0xFF4286f4)
    ], // Slate to saturated blue
    [
      const Color(0xFF141E30),
      const Color(0xFF243B55)
    ], // Midnight blue to steel
    [
      const Color(0xFF000428),
      const Color(0xFF004e92)
    ], // Black-blue to royal blue
    [const Color(0xFF434343), const Color(0xFF000000)], // Graphite to black
    [const Color(0xFF3E5151), const Color(0xFFDECBA4)], // Dark teal to gold
    [const Color(0xFF283E51), const Color(0xFF485563)], // Deep blue to slate
    [const Color(0xFF232526), const Color(0xFF4B6CB7)], // Charcoal to blue
    [
      const Color(0xFF1D4350),
      const Color(0xFFA43931)
    ], // Deep blue to burnt orange
    [
      const Color(0xFF20002c),
      const Color(0xFFcbb4d4)
    ], // Deep purple to pale lavender
  ];
  final PageController _verticalCtrl = PageController();
  int _currentGradientIndex = 0;

  List<Color> get _currentGradient => _gradients[_currentGradientIndex];

  void _changeGradient() {
    setState(() {
      _currentGradientIndex = math.Random().nextInt(_gradients.length);
    });
  }

  void _shareQuote(TitleQuote quote) {
    QuoteShareUtils.shareQuote(quote, subject: 'Quote of the Day');
  }

  void _addToHomeScreen(TitleQuote quote) {
    HomeScreenWidgetUtils.addToHomeScreen(context, quote, _currentGradient);
  }

  @override
  Widget build(BuildContext context) {
    final stream = liveProvider.fetchMultiple<TitleQuote>(
      '*[_type == "quote"]',
      fromJson: TitleQuote.fromJson,
    );

    return StreamBuilder<List<TitleQuote>?>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
                body: Center(child: CircularProgressIndicator()));
          }
          if (snapshot.hasError) {
            return Scaffold(
                body: Center(child: Text('Error: ${snapshot.error}')));
          }
          final data = snapshot.data ?? const <TitleQuote>[];
          if (data.isEmpty) {
            return const Scaffold(body: Center(child: Text('No quotes found')));
          }

          final quotes = List<TitleQuote>.from(data)..shuffle();

          return Scaffold(
              body: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onHorizontalDragEnd: (details) {
                    final v = details.primaryVelocity ?? 0;
                    if (v < -300) {
                      context.go('/quote_list');
                    }
                  },
                  child: Stack(children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _currentGradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                    PageView.builder(
                        controller: _verticalCtrl,
                        scrollDirection: Axis.vertical,
                        physics: const BouncingScrollPhysics(),
                        onPageChanged: (_) => _changeGradient(),
                        itemCount: quotes.length,
                        itemBuilder: (context, index) {
                          final obj = quotes[index];
                          return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 40),
                              child: Stack(
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: const Text(
                                          '“',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 64,
                                            fontWeight: FontWeight.bold,
                                            height: 0.5,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Center(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              const SizedBox(height: 12),
                                              Text(
                                                obj.quote,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 24,
                                                  height: 1.4,
                                                ),
                                              ),
                                              const SizedBox(height: 16),
                                              Text(
                                                '- ${obj.author}',
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          IconButton(
                                            onPressed: () => _shareQuote(obj),
                                            icon: const Icon(Icons.share,
                                                color: Colors.white),
                                          ),
                                          ValueListenableBuilder<Set<String>>(
                                            valueListenable: favoritesNotifier,
                                            builder: (_, __, ___) => IconButton(
                                              onPressed: () =>
                                                  toggleFavorite(obj.id),
                                              icon: Icon(
                                                isFavorite(obj.id)
                                                    ? Icons.favorite
                                                    : Icons.favorite_border,
                                                color: Colors.pinkAccent,
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () =>
                                                _addToHomeScreen(obj),
                                            icon: const Icon(
                                                Icons.add_to_home_screen,
                                                color: Colors.white),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                    ],
                                  ),
                                ],
                              ));
                        })
                  ])));
        });
  }
}
