# Smart Mediation Adapters iOS - AdinCube

## Native ad integration

The _AdinCube_ native adapter requires you to implement a ```SASMediaView``` (this media view will automatically delegates the rendering to a ```AdinCubeNativeAdMediaView``` view). If you forget to do so, you might display an ad that will not be paid (depending of the ad network).

Please note that the _AdinCube_ native adapter does not handle the ```AdinCubeNativeAdIconView``` which might prevent some network (like Facebook) to answer.
