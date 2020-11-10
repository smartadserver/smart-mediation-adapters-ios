# Smart Mediation Adapters Android - Vungle

## Known issue

### Manual adapters installation

We cannot provide automatic Vungle integration through Cocoapods at the moment due to an issue with Xcode 12.

You can install these mediation adapters manually by **copying all files from this directory into your project**, then adding both MoPub and Smart SDK to your Podfile:

```
pod "Smart-Display-SDK"
pod "VungleSDK-iOS", "~> 6.8.1"
```