# Smart Mediation Adapters iOS - MoPub

## Known issue

The _MoPub_ banner loading will fail if the _SASBannerView_ has an invalid frame (like _CGZero_) when the _load(with:)_ method is called.


### Click counting discrepancy

Only the interstitial adapter is counting clicks. All other formats don't.
