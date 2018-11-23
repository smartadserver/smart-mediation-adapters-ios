# Smart Mediation Adapters iOS - TapJoy

## Note

__TapJoy__ rewarded video API will always use the reward set in _Manage_ insertion, not the one set on __TapJoy__.

If you want to use __TapJoy__ reward, simply ignore the reward sent by __Smart Display SDK__ reward delegate and call the relevant __TapJoy__ API to get your current currency balance instead.

## Known issue

Some __TapJoy__ interstitials and rewarded video ads display seems to be broken on some devices when your application also link to __Google Mobile Ads__ framework with version _7.28_ and _7.29_. Make sure you do not use these versions of __Google Mobile Ads__ if you plan to use both networks.
