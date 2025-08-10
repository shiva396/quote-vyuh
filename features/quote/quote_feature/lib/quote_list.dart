import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vyuh_core/vyuh_core.dart';
import 'package:flutter/foundation.dart';

class TitleQuote {
  final String id;
  final String quote;
  final String author;

  TitleQuote({required this.id, required this.quote, required this.author});

  factory TitleQuote.fromJson(Map<String, dynamic> json) {
    // String authorText = '';
    // if (json['author'] != null &&
    //     json['author'] is List &&
    //     json['author'].isNotEmpty &&
    //     json['author'][0]['children'] != null &&
    //     json['author'][0]['children'].isNotEmpty) {
    //   authorText = json['author'][0]['children'][0]['text'] ?? '';
    // }
    print('json: $json');
    return TitleQuote(
      id: json['_id'] ?? '',
      quote: json['quote'] ?? 'helo',
      author: json['author'] ?? 'hello',
    );
  }
}

final liveProvider = vyuh.content.provider.live;

final ValueNotifier<Set<String>> favoritesNotifier =
    ValueNotifier<Set<String>>(<String>{});

bool isFavorite(String id) => favoritesNotifier.value.contains(id);

void toggleFavorite(String id) {
  final next = Set<String>.from(favoritesNotifier.value);
  if (next.contains(id)) {
    next.remove(id);
  } else {
    next.add(id);
  }
  favoritesNotifier.value = next;
}

class QuoteListPage extends StatefulWidget {
  const QuoteListPage({super.key});

  @override
  State<QuoteListPage> createState() => _QuoteListPageState();
}

class _QuoteListPageState extends State<QuoteListPage> {
  bool showFavoritesOnly = false;
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final titlesStream = liveProvider.fetchMultiple<TitleQuote>(
      '*[_type == "quote"]',
      fromJson: TitleQuote.fromJson,
    );

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Quotes'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          ValueListenableBuilder<Set<String>>(
            valueListenable: favoritesNotifier,
            builder: (context, favs, _) => IconButton(
              tooltip:
                  showFavoritesOnly ? 'Show all quotes' : 'Show favorites only',
              onPressed: () =>
                  setState(() => showFavoritesOnly = !showFavoritesOnly),
              icon: Icon(
                showFavoritesOnly ? Icons.favorite : Icons.favorite_border,
                color: showFavoritesOnly ? Colors.pinkAccent : null,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surface,
            child: TextField(
              controller: _searchController,
              onChanged: (value) =>
                  setState(() => searchQuery = value.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search quotes or authors...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.background,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragEnd: (details) {
                final v = details.primaryVelocity ?? 0;
                if (v > 300) {
                  context.go('/quote_screen');
                }
              },
              child: StreamBuilder<List<TitleQuote>?>(
                stream: titlesStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No data found'));
                  }

                  var quotes = snapshot.data!;

                  if (showFavoritesOnly) {
                    quotes = quotes.where((q) => isFavorite(q.id)).toList();
                  }

                  if (searchQuery.isNotEmpty) {
                    quotes = quotes
                        .where((q) =>
                            q.quote.toLowerCase().contains(searchQuery) ||
                            q.author.toLowerCase().contains(searchQuery))
                        .toList();
                  }

                  if (quotes.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            showFavoritesOnly
                                ? Icons.favorite_border
                                : Icons.search_off,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            showFavoritesOnly
                                ? 'No favorite quotes yet'
                                : searchQuery.isNotEmpty
                                    ? 'No quotes found'
                                    : 'No quotes available',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                          ),
                          if (showFavoritesOnly) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Tap the ♥ icon on quotes to add them to favorites',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.grey.shade500,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: quotes.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final obj = quotes[index];
                      final isFav = isFavorite(obj.id);

                      return Card(
                        elevation: 2,
                        shadowColor: Colors.black.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '"${obj.quote}"',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w500,
                                            height: 1.5,
                                            fontSize: 16,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(20),
                                      onTap: () => toggleFavorite(obj.id),
                                      child: Padding(
                                        padding: const EdgeInsets.all(4),
                                        child: Icon(
                                          isFav
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color: isFav
                                              ? Colors.pinkAccent
                                              : Colors.grey.shade400,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '— ${obj.author}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            fontStyle: FontStyle.italic,
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                  ),
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(20),
                                      onTap: () {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: const Text(
                                                'Share functionality coming soon!'),
                                            duration:
                                                const Duration(seconds: 2),
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            action: SnackBarAction(
                                              label: 'Preview',
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      AlertDialog(
                                                    title: const Text(
                                                        'Share Preview'),
                                                    content: Text(
                                                      '"${obj.quote}"\n\n— ${obj.author}',
                                                      style: const TextStyle(
                                                          height: 1.5),
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.of(
                                                                    context)
                                                                .pop(),
                                                        child:
                                                            const Text('Close'),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(4),
                                        child: Icon(
                                          Icons.share_outlined,
                                          size: 18,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
