# Smart Mediation Adapters iOS

This repository contains all mediation adapters we officially support.

## Cocoapods installation

You can install the __Smart Display SDK__, one or several mediation adapters and their related third party SDKs using _Cocoapods_.

For that, simply declare the pod ```Smart-Display-SDK-With-Mediation``` in your _podfile_ (__instead of the regular Smart-Display-SDK__) with the appropriate _subspec_. For instance you can import _InMobi_ and _Tapjoy_ like so:

```
pod 'Smart-Display-SDK-With-Mediation/InMobi'
pod 'Smart-Display-SDK-With-Mediation/Tapjoy'
```

Available _subspecs_ are:

| Subspec name | Supported SDK version | Comments |
| ------------ | --------------------- | -------- |
| ```AdColony``` | ~> 3.3.0 | _n/a_ |
| ```AppLovin``` | ~> 6.2.0 | _n/a_ |
| ```FacebookAudienceNetwork``` | ~> 6.3.0 | _n/a_ |
| ```GoogleMobileAds``` | ~> 8.1.0 | _n/a_ |
| ```InMobi``` | ~> 7.2.0 | _n/a_ |
| ```MoPub``` | ~> 5.16.2 | _n/a_ |
| ```Ogury``` | ~> 2.3.0 | _n/a_ |
| ```Tapjoy``` | ~> 12.8.0 | _n/a_ |
| ```Vungle``` | ~> 6.9.1 | _n/a_ |

__Note:__ if you install the pod _Smart-Display-SDK-With-Mediation_ without specifying any _subspec_, only the __Smart Display SDK__ will be installed.

## Manual installation

You can still install the adapters manually if needed:

1. First make sure you have installed the __Smart Display SDK__. More information [here](http://documentation.smartadserver.com/DisplaySDK/ios/gettingstarted.html).

2. Copy and paste the classes of the adapter(s) you need to your project sources. Note that some adapter classes have a base class, do not forget to copy it as well.

3. Make sure to integrate the SDK corresponding to the chosen adapter(s).
