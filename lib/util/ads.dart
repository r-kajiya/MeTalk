import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';

typedef RewardCallback = void Function();

class Ads {
  static Ads _instance;

  Ads._();

  factory Ads() {
    if (_instance == null) {
      _instance = new Ads._();
    }

    return _instance;
  }

  setup() {
    MobileAds.instance.initialize();
  }

  loadAndShow(RewardCallback rewardCallback) {
    String adUnitId = 'ca-app-pub-3940256099942544/5224354917';

    RewardedAd.load(
        adUnitId: adUnitId,
        request: AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdShowedFullScreenContent: (RewardedAd ad) =>
                  print('$ad onAdShowedFullScreenContent.'),
              onAdDismissedFullScreenContent: (RewardedAd ad) {
                print('$ad onAdDismissedFullScreenContent.');
                ad.dispose();
              },
              onAdFailedToShowFullScreenContent:
                  (RewardedAd ad, AdError error) {
                print('$ad onAdFailedToShowFullScreenContent: $error');
                ad.dispose();
              },
              onAdImpression: (RewardedAd ad) =>
                  print('$ad impression occurred.'),
            );

            ad.show(onUserEarnedReward: (RewardedAd ad, RewardItem rewardItem) {
              rewardCallback();
            });
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('RewardedAd failed to load: $error');
          },
        ));
  }
}
