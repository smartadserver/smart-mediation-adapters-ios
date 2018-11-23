//
//  SASAppLovinNativeAdapter.m
//  SmartAdServer
//
//  Created by Loïc GIRON DIT METAZ on 18/09/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import "SASAppLovinNativeAdAdapter.h"
#import <SASDisplayKit/SASDisplayKit.h>

NS_ASSUME_NONNULL_BEGIN

@implementation SASAppLovinNativeAdAdapter

#pragma mark - Mediation adapter protocol implementation

- (void)dealloc {
    if (self.registeredGestureRecognizers != nil) {
        [self unregisterViews];
    }
}

- (instancetype)initWithDelegate:(id<SASMediationNativeAdAdapterDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
    }
    return self;
}

- (void)requestNativeAdWithServerParameterString:(NSString *)serverParameterString clientParameters:(NSDictionary *)clientParameters {
    self.nativeAd = nil;
    
    // Initializing the SDK is done in the base class
    [SASAppLovinBaseAdapter initializeAppLovin];
    
    // Configuring GDPR is done in the base class
    [self configureGDPRWithClientParameters:clientParameters];
    
    // Using the native ad service to load an ad…
    [[ALSdk shared].nativeAdService loadNativeAdGroupOfCount:1 andNotify:self];
}

- (void)registerView:(UIView *)view tappableViews:(nullable NSArray *)tappableViews overridableViews:(NSDictionary *)overridableViews fromViewController:(UIViewController *)viewController {
    
    // Filling the tappableViews array with 'view' if it is empty
    if (!tappableViews || [tappableViews count] == 0) {
        tappableViews = [NSArray arrayWithObject:view];
    }
    
    // Removing SASNativeMediaViews from tappableViews
    NSMutableArray *views = [NSMutableArray arrayWithArray:tappableViews];
    if ([overridableViews objectForKey:SASMediationOverridableNativeAdMediaView]) {
        [views removeObject:[overridableViews objectForKey:SASMediationOverridableNativeAdMediaView]];
    }
    
    // Creating an array to store gesture recognizers that will have to be removed later
    self.registeredGestureRecognizers = [NSMutableArray array];
    
    // Add gesture recognizers to make them tappable
    for (UIView *aView in views) {
        aView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGestureRecognizer = [self configuredTapGestureRecognizer];
        [aView addGestureRecognizer:tapGestureRecognizer];
        
        [self.registeredGestureRecognizers addObject:tapGestureRecognizer];
    }
    
}

- (void)unregisterViews {
    // Removing all pending gesture recognizers
    for (UITapGestureRecognizer *tapGestureRecognizer in self.registeredGestureRecognizers) {
        [tapGestureRecognizer.view removeGestureRecognizer:tapGestureRecognizer];
    }
    
    // The array is set to nil to indicates that there is no more registed views
    self.registeredGestureRecognizers = nil;
}

- (nullable NSURL *)adChoicesURL {
    return [NSURL URLWithString:@"http://applovin.com/optoutmobile"];
}


- (BOOL)hasMedia {
    return self.nativeAd.videoURL != nil;
}


- (nullable UIView *)mediaView {
    return nil; // The media will be handled automatically by Smart media view
}

#pragma mark - AppLovin native ad delegate

- (void)nativeAdService:(ALNativeAdService *)service didLoadAds:(NSArray *)ads {
    self.nativeAd = [ads firstObject];
    SASMediationNativeAdInfo *nativeAdInfo = [self smartNativeAdFromAppLovinAd:self.nativeAd];
    [self.delegate mediationNativeAdAdapter:self didLoadAdInfo:nativeAdInfo];
}

- (void)nativeAdService:(ALNativeAdService *)service didFailToLoadAdsWithError:(NSInteger)code {
    NSError *error = [NSError errorWithDomain:SASAppLovinAdapterErrorDomain code:code userInfo:@{ NSLocalizedDescriptionKey: [NSString stringWithFormat:@"AppLovin Native Error: %ld", (long)code] }];
    [self.delegate mediationNativeAdAdapter:self didFailToLoadWithError:error noFill:(code == kALErrorCodeNoFill)];
}

#pragma mark - Util methods

- (SASMediationNativeAdInfo *)smartNativeAdFromAppLovinAd:(ALNativeAd *)nativeAd {
    SASMediationNativeAdInfo *nativeAdInfo = [[SASMediationNativeAdInfo alloc] initWithTitle:nativeAd.title];
    
    nativeAdInfo.subtitle = nativeAd.descriptionText;
    nativeAdInfo.callToAction = nativeAd.ctaText;
    nativeAdInfo.rating = [nativeAd.starRating floatValue];
    
    if (nativeAd.imageURL) {
        nativeAdInfo.coverImage = [[SASNativeAdImage alloc] initWithURL:nativeAd.imageURL];
    }
    
    if (nativeAd.iconURL) {
        nativeAdInfo.icon = [[SASNativeAdImage alloc] initWithURL:nativeAd.iconURL];
    }
    
    if (nativeAd.videoURL) {
        // Extracting video URL
        nativeAdInfo.videoURL = nativeAd.videoURL;
        
        // Extracting video tracking events
        NSURL *startURL = nativeAd.videoStartTrackingURL;
        NSURL *completeURL = [nativeAd videoEndTrackingURL:100 firstPlay:YES];
        if (startURL != nil && completeURL != nil) {
            nativeAdInfo.videoTrackingEvents = @{ @"start": startURL, @"complete": completeURL };
        }
    }
    
    _Pragma("clang diagnostic push")\
    _Pragma("clang diagnostic ignored \"-Wdeprecated-declarations\"")\
    // Warning: getting impression URLs from the AppLovin ad object is deprecated and might be impossible in future versions
    nativeAdInfo.impressionURLs = @[[nativeAd.impressionTrackingURL copy]];
    _Pragma("clang diagnostic pop")
    
    return nativeAdInfo;
}


- (UITapGestureRecognizer *)configuredTapGestureRecognizer {
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(maskViewTapped:)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    
    return tapGestureRecognizer;
}

- (void)maskViewTapped:(id)sender {
    [self.nativeAd launchClickTarget];
    [self.delegate mediationNativeAdAdapterDidReceiveAdClickedEvent:self];
}

@end

NS_ASSUME_NONNULL_END
