import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../quote_list.dart';

class QuoteShareUtils {
  /// Share a quote using the device's sharing functionality
  static Future<void> shareQuote(TitleQuote quote, {String? subject}) async {
    try {
      final text = _formatQuoteForSharing(quote);
      await Share.share(
        text,
        subject: subject ?? 'Quote of the Day',
      );
    } catch (e) {
      debugPrint('Error sharing quote: $e');
    }
  }

  /// Share a quote with additional context and formatting options
  static Future<void> shareQuoteWithOptions(
    BuildContext context,
    TitleQuote quote,
  ) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle indicator
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Share Quote',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose how you\'d like to share this quote',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 20),

            // Quote preview
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '"${quote.quote}"',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontStyle: FontStyle.italic,
                          height: 1.4,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '— ${quote.author}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Share options
            _buildShareOption(
              context,
              icon: Icons.share,
              title: 'Share as Text',
              subtitle: 'Share via messaging, email, etc.',
              color: Colors.blue,
              onTap: () {
                Navigator.pop(context);
                shareQuote(quote);
              },
            ),
            _buildShareOption(
              context,
              icon: Icons.copy,
              title: 'Copy to Clipboard',
              subtitle: 'Copy formatted quote text',
              color: Colors.green,
              onTap: () {
                Navigator.pop(context);
                copyToClipboard(context, quote);
              },
            ),
            _buildShareOption(
              context,
              icon: Icons.format_quote,
              title: 'Share as Image',
              subtitle: 'Create a quote image to share',
              color: Colors.purple,
              onTap: () {
                Navigator.pop(context);
                _showImageShareDialog(context, quote);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// Copy quote text to clipboard
  static Future<void> copyToClipboard(
      BuildContext context, TitleQuote quote) async {
    try {
      final text = _formatQuoteForSharing(quote);
      await Clipboard.setData(ClipboardData(text: text));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Quote copied to clipboard'),
              ],
            ),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error copying to clipboard: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to copy quote'),
            backgroundColor: Colors.red[600],
          ),
        );
      }
    }
  }

  /// Format quote text for sharing
  static String _formatQuoteForSharing(TitleQuote quote) {
    return '💭 *Quote of the Day*\n\n"${quote.quote}"\n\n— ${quote.author}\n\n📱 Shared via Quote Vyuh';
  }

  /// Format quote text for clipboard (simpler format)
  static String _formatQuoteForClipboard(TitleQuote quote) {
    return '"${quote.quote}"\n\n— ${quote.author}';
  }

  /// Build share option tile
  static Widget _buildShareOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: onTap,
    );
  }

  /// Show image share dialog (placeholder for future implementation)
  static void _showImageShareDialog(BuildContext context, TitleQuote quote) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.image, color: Colors.purple),
            SizedBox(width: 8),
            Text('Image Sharing'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.construction, size: 48, color: Colors.orange),
            SizedBox(height: 16),
            Text(
              'Image sharing feature is coming soon!\n\nThis will allow you to create beautiful quote images with custom backgrounds and fonts.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              shareQuote(quote);
            },
            child: const Text('Share as Text'),
          ),
        ],
      ),
    );
  }

  /// Get sharing statistics (for future analytics)
  static Map<String, dynamic> getSharingStats() {
    return {
      'totalShares': 0, // This would be tracked in a real implementation
      'shareTypes': {
        'text': 0,
        'clipboard': 0,
        'image': 0,
      },
      'lastSharedAt': null,
    };
  }
}
