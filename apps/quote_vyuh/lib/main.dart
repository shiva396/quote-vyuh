import 'package:feature_counter/feature_counter.dart' as counter;
import 'package:quote_feature/quote_feature.dart' as quote;
import 'package:vyuh_core/vyuh_core.dart' as vc;
import 'package:vyuh_feature_developer/vyuh_feature_developer.dart'
    as developer;
import 'package:vyuh_feature_system/vyuh_feature_system.dart' as system;

void main() async {
  vc.runApp(
    initialLocation: '/quote_screen',
    features: () => [
      system.feature,
      developer.feature,
      counter.feature,
      quote.feature
    ],
  );
}
