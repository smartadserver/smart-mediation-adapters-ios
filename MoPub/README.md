# Smart Mediation Adapters iOS - MoPub

## Known issue

### Manual adapters installation

We cannot provide automatic MoPub integration through Cocoapods at the moment due to an issue with Xcode 12.

You can install these mediation adapters manually by **copying all files from this directory into your project**, then adding both MoPub and Smart SDK to your Podfile:

```
pod "Smart-Display-SDK"
pod "mopub-ios-sdk", "~> 5.6.0"
```