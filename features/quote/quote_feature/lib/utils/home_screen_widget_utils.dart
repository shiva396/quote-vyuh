import 'package:flutter/material.dart';
import '../quote_list.dart';

class HomeScreenWidgetUtils {
  // In-memory storage for widget configurations (for demo purposes)
  static final List<Map<String, dynamic>> _widgetConfigs = [];
  static int _widgetIdCounter = 1;

  /// Add a quote to home screen widget with size options
  static Future<void> addToHomeScreen(
    BuildContext context,
    TitleQuote quote,
    List<Color> currentGradient,
  ) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _WidgetConfigurationSheet(
        quote: quote,
        currentGradient: currentGradient,
      ),
    );
  }

  /// Store widget configuration for home screen widget
  static Future<bool> storeWidgetConfig(Map<String, dynamic> config) async {
    try {
      _widgetConfigs.add(config);
      return true;
    } catch (e) {
      debugPrint('Error storing widget config: $e');
      return false;
    }
  }

  /// Get all stored widget configurations
  static Future<List<Map<String, dynamic>>> getStoredWidgetConfigs() async {
    return List<Map<String, dynamic>>.from(_widgetConfigs);
  }

  /// Get widget configuration by ID
  static Future<Map<String, dynamic>?> getWidgetConfig(String widgetId) async {
    try {
      return _widgetConfigs.firstWhere((config) => config['id'] == widgetId);
    } catch (e) {
      return null;
    }
  }

  /// Remove widget configuration
  static Future<bool> removeWidgetConfig(String widgetId) async {
    try {
      _widgetConfigs.removeWhere((config) => config['id'] == widgetId);
      return true;
    } catch (e) {
      debugPrint('Error removing widget config: $e');
      return false;
    }
  }

  /// Get total number of active widgets
  static Future<int> getWidgetCount() async {
    return _widgetConfigs.length;
  }

  /// Generate unique widget ID
  static String generateWidgetId() {
    return 'widget_${_widgetIdCounter++}_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Get widget data for native Android widget
  static Map<String, dynamic> formatWidgetData(
    TitleQuote quote,
    String size,
    List<Color> gradient,
  ) {
    return {
      'id': generateWidgetId(),
      'quote': quote.quote,
      'author': quote.author,
      'quoteId': quote.id,
      'size': size,
      'gradient': {
        'startColor': gradient[0].value,
        'endColor': gradient[1].value,
      },
      'createdAt': DateTime.now().toIso8601String(),
      'lastUpdated': DateTime.now().toIso8601String(),
    };
  }

  /// Create widget configuration and show success
  static Future<void> createWidget(
    BuildContext context,
    TitleQuote quote,
    String size,
    List<Color> gradient,
  ) async {
    // Create widget configuration
    final widgetConfig = formatWidgetData(quote, size, gradient);

    // Store configuration
    final success = await storeWidgetConfig(widgetConfig);

    if (!context.mounted) return;

    if (success) {
      // Show success dialog
      showDialog(
        context: context,
        builder: (context) => _WidgetSuccessDialog(
          quote: quote,
          size: size,
          gradient: gradient,
          widgetId: widgetConfig['id'],
        ),
      );
    } else {
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Text('Failed to create widget'),
            ],
          ),
          backgroundColor: Colors.red[600],
        ),
      );
    }
  }
}

class _WidgetConfigurationSheet extends StatelessWidget {
  final TitleQuote quote;
  final List<Color> currentGradient;

  const _WidgetConfigurationSheet({
    required this.quote,
    required this.currentGradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            'Add to Home Screen',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose widget size for your home screen',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 24),

          // Widget preview
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
                  'Quote Preview',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  '"${quote.quote}"',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '— ${quote.author}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Widget size options
          _buildWidgetOption(
            context,
            icon: Icons.crop_din,
            title: 'Small Widget',
            subtitle: '2×1 • Perfect for quick quotes',
            size: 'small',
            color: Colors.blue,
          ),
          _buildWidgetOption(
            context,
            icon: Icons.view_agenda,
            title: 'Medium Widget',
            subtitle: '4×2 • Standard quote display',
            size: 'medium',
            color: Colors.green,
          ),
          _buildWidgetOption(
            context,
            icon: Icons.fullscreen,
            title: 'Large Widget',
            subtitle: '4×3 • Full quote with background',
            size: 'large',
            color: Colors.purple,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildWidgetOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String size,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
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
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.pop(context);
          HomeScreenWidgetUtils.createWidget(
            context,
            quote,
            size,
            currentGradient,
          );
        },
      ),
    );
  }
}

class _WidgetSuccessDialog extends StatelessWidget {
  final TitleQuote quote;
  final String size;
  final List<Color> gradient;
  final String widgetId;

  const _WidgetSuccessDialog({
    required this.quote,
    required this.size,
    required this.gradient,
    required this.widgetId,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.widgets, color: Theme.of(context).primaryColor),
          const SizedBox(width: 8),
          const Text('Widget Created!'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your ${size} quote widget has been configured and is ready to add to your home screen.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),

          // Widget preview
          Center(
            child: _buildWidgetPreview(),
          ),
          const SizedBox(height: 16),

          // Instructions
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.blue[700]),
                    const SizedBox(width: 4),
                    Text(
                      'How to add to home screen:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  '1. Long press on your home screen\n'
                  '2. Tap "Widgets"\n'
                  '3. Find "Quote Vyuh"\n'
                  '4. Select your configured widget',
                  style: TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Got it'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
            _showWidgetPreview(context);
          },
          icon: const Icon(Icons.preview, size: 16),
          label: const Text('Preview'),
        ),
      ],
    );
  }

  Widget _buildWidgetPreview() {
    final maxLength = size == 'small'
        ? 30
        : size == 'medium'
            ? 60
            : 100;
    final displayQuote = quote.quote.length > maxLength
        ? '${quote.quote.substring(0, maxLength)}...'
        : quote.quote;

    switch (size) {
      case 'small':
        return Container(
          width: 120,
          height: 60,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                displayQuote,
                style: const TextStyle(color: Colors.white, fontSize: 8),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                '— ${quote.author}',
                style: const TextStyle(color: Colors.white70, fontSize: 6),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      case 'medium':
        return Container(
          width: 160,
          height: 80,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                displayQuote,
                style: const TextStyle(color: Colors.white, fontSize: 10),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '— ${quote.author}',
                style: const TextStyle(color: Colors.white70, fontSize: 8),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      case 'large':
      default:
        return Container(
          width: 200,
          height: 120,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '"',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                displayQuote,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                textAlign: TextAlign.center,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                '— ${quote.author}',
                style: const TextStyle(color: Colors.white70, fontSize: 10),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
    }
  }

  void _showWidgetPreview(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Widget Preview - ${size.toUpperCase()}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              _buildWidgetPreview(),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      final count =
                          await HomeScreenWidgetUtils.getWidgetCount();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'You now have $count widget(s) configured'),
                            backgroundColor: Colors.green[600],
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.info, size: 16),
                    label: const Text('Widget Info'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
