import 'package:quote_feature/quote_feature.dart' as quote;
import 'package:flutter/material.dart';
import 'package:vyuh_core/plugin/plugin_descriptor.dart';
import 'package:vyuh_core/vyuh_core.dart' as vc;
import 'package:vyuh_extension_content/plugin/content_plugin.dart';
import 'package:vyuh_feature_developer/vyuh_feature_developer.dart'
    as developer;
import 'package:vyuh_feature_system/vyuh_feature_system.dart' as system;

import 'package:vyuh_plugin_content_provider_sanity/vyuh_plugin_content_provider_sanity.dart';
import 'package:sanity_client/sanity_client.dart';

void main() async {
  vc.runApp(
    initialLocation: '/quote_screen',
    features: () => [quote.feature],
    plugins: _getPlugins(),
  );
}

PluginDescriptor _getPlugins() {
  WidgetsFlutterBinding.ensureInitialized();
  return PluginDescriptor(
    content: DefaultContentPlugin(
      useLiveRoute: true,
      allowRouteRefresh: true,
      provider: SanityContentProvider(
        SanityClient(
          SanityConfig(
            projectId: vc.vyuh.env.get('QUOTE_PROJECTID'),
            dataset: 'production',
            token: vc.vyuh.env.get('QUOTE_TOKEN'),
            perspective: Perspective.drafts,
            explainQuery: true,
            useCdn: false,
          ),
        ),
      ),
    ),
  );
}
