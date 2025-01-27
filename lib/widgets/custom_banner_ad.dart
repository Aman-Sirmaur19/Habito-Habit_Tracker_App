import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../secrets.dart';

class CustomBannerAd extends StatefulWidget {
  const CustomBannerAd({super.key});

  @override
  State<CustomBannerAd> createState() => _CustomBannerAdState();
}

class _CustomBannerAdState extends State<CustomBannerAd> {
  late BannerAd _bannerAd;
  bool _isBannerAdLoaded = false;
  late NativeAd _nativeAd;
  bool _isNativeAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _initializeNativeAd();
  }

  Future<void> _initializeBannerAd() async {
    _bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: Secrets.bannerAdId,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isBannerAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _isBannerAdLoaded = false;
          log('Failed to load banner ad: ${error.message}');
        },
      ),
    );
    try {
      _bannerAd.load();
    } catch (error) {
      log('Error loading banner ad: $error');
      setState(() {
        _isBannerAdLoaded = false;
      });
    }
  }

  Future<void> _initializeNativeAd() async {
    _nativeAd = NativeAd(
      adUnitId: Secrets.nativeAdId,
      request: const AdRequest(),
      nativeTemplateStyle:
          NativeTemplateStyle(templateType: TemplateType.small),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isNativeAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          log('Failed to load native ad: ${error.message}');
          ad.dispose();
          setState(() {
            _isNativeAdLoaded = false;
          });
          _initializeBannerAd();
        },
      ),
    );
    try {
      await _nativeAd.load();
    } catch (error) {
      log('Error loading native ad: $error');
      setState(() {
        _isNativeAdLoaded = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isNativeAdLoaded
        ? SizedBox(height: 85, child: AdWidget(ad: _nativeAd))
        : _isBannerAdLoaded
            ? SizedBox(height: 50, child: AdWidget(ad: _bannerAd))
            : const SizedBox();
  }
}
