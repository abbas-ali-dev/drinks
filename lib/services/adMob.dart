import 'package:drinks/global/global_variable.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/material.dart';

class AdHelper {
  static BannerAd? createBannerAd(void Function() onAdLoaded) {
    return BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111',
      size: AdSize.fullBanner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => onAdLoaded(),
        onAdFailedToLoad: (ad, error) => ad.dispose(),
      ),
    )..load();

    // return null;
  }

  static Widget getBannerAdWidget(BannerAd? bannerAd) {
    if (showAdMobGlobally.value == false || bannerAd == null) {
      return const SizedBox(
        height: 10,
      );
    } else {
      return Container(
        alignment: Alignment.center,
        width: bannerAd.size.width.toDouble(),
        height: bannerAd.size.height.toDouble(),
        child: AdWidget(ad: bannerAd),
      );
    }
  }
}
