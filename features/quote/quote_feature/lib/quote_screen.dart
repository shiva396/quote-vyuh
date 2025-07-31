import 'package:flutter/material.dart';

class QuoteScreen extends StatelessWidget {
  final String quoteText;
  final String quoteAuthor; // Default author
  final String quoteDate;
  final List<Color> backgroundGradient;

  const QuoteScreen({
    super.key,
    required this.quoteText,
    this.quoteAuthor = "Unknown Author",
    required this.quoteDate,
    this.backgroundGradient = const [Color(0xFF232526), Color(0xFF414345)],
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: backgroundGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Align(
              alignment: Alignment.topLeft,
              child: Text(
                "“",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  height: 0.5,
                ),
              ),
            ),
            Center(
              child: Column(
                children: [
                  Text(
                    quoteText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26,
                      color: Colors.white,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  SizedBox(height: 32),
                  Text("~ $quoteAuthor",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                      )),
                ],
              ),
            ),
            Column(
              children: [
                Text(
                  quoteDate,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.share, color: Colors.white70),
                      onPressed: () {
                        // Share logic here
                      },
                    ),
                    const SizedBox(width: 24),
                    IconButton(
                      icon: const Icon(Icons.favorite, color: Colors.redAccent),
                      onPressed: () {
                        // Like logic here
                      },
                    ),
                    const SizedBox(width: 24),
                    IconButton(
                      icon: const Icon(Icons.cloud_download,
                          color: Colors.white70),
                      onPressed: () {
                        // Download logic here
                      },
                    ),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
