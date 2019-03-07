//
//  SASAdinCubeNativeAdapter.m
//  SmartAdServer
//
//  Created by Loïc GIRON DIT METAZ on 12/09/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import "SASAdinCubeNativeAdapter.h"
#import <SASDisplayKit/SASDisplayKit.h>

NS_ASSUME_NONNULL_BEGIN

@implementation SASAdinCubeNativeAdapter

#pragma mark - Mediation adapter protocol implementation

- (void)dealloc {
    if (self.viewRegistered) {
        [self unregisterViews];
    }
    [self.native destroy:self.nativeAd];
}

- (instancetype)initWithDelegate:(id<SASMediationNativeAdAdapterDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
        self.viewRegistered = NO;
    }
    return self;
}

- (void)requestNativeAdWithServerParameterString:(NSString *)serverParameterString clientParameters:(NSDictionary *)clientParameters {
    self.nativeAd = nil;
    
    // Configuring Application ID is done in the base class
    [self configureApplicationIDWithServerParameterString:serverParameterString];
    
    // Configuring GDPR is done in the base class
    [self configureGDPRWithClientParameters:clientParameters];
    
    // Loading ad…
    self.native = [[AdinCubeNative alloc] init];
    
    AdinCubeNativeAdOptions *options = [[[[AdinCubeNativeAdOptions newBuilder] withNbAds:1] usesMediaViewForCover] build];
    [self.native loadWithOptions:options delegate:self];
}

- (void)registerView:(UIView *)view tappableViews:(nullable NSArray *)tappableViews overridableViews:(NSDictionary *)overridableViews fromViewController:(UIViewController *)viewController {
    self.viewRegistered = YES;
    
    // Filling the tappableViews array with 'view' if it is empty
    if (!tappableViews || [tappableViews count] == 0) {
        tappableViews = [NSArray arrayWithObject:view];
    }

    // Overriding the Smart media view
    UIView *nativeAdMediaView = [overridableViews objectForKey:SASMediationOverridableNativeAdMediaView];
    if (nativeAdMediaView != nil && [self hasMedia]) {
        // Create Ad In Cube Native Ad MediaView
        self.adInCubeMediaView = [[AdinCubeNativeAdMediaView alloc] initWithFrame:nativeAdMediaView.bounds];
        self.adInCubeMediaView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.adInCubeMediaView.nativeAd = self.nativeAd;
        self.adInCubeMediaView.autoPlay = YES;
        nativeAdMediaView.userInteractionEnabled = NO;
        self.adInCubeMediaView.userInteractionEnabled = YES;
        [nativeAdMediaView addSubview:self.adInCubeMediaView];
    }
    
    // Overriding the Smart ad choices view
    UIView *adChoicesView = [overridableViews objectForKey:SASMediationOverridableAdChoicesView];
    if (adChoicesView != nil) {
        // Create Ad In Cube Native AdChoiceView
        self.adInCubeAdChoiceView = [[AdinCubeAdChoicesView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(adChoicesView.frame), CGRectGetHeight(adChoicesView.frame))];
        self.adInCubeAdChoiceView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.adInCubeAdChoiceView.nativeAd = self.nativeAd;
        [adChoicesView addSubview:self.adInCubeAdChoiceView];
        adChoicesView.hidden = ![self.nativeAd.network isEqualToString:@"Facebook"];
    }
    
    // Linking the AdinCube native ad to the views retrieved from the Smart SDK
    [self.native link:self.nativeAd toView:view andViewController:viewController];
}

- (void)unregisterViews {
    self.viewRegistered = NO;
    
    // Remove adInCubeMediaView
    if (self.adInCubeMediaView) {
        self.adInCubeMediaView.nativeAd = nil;
        [self.adInCubeMediaView removeFromSuperview];
        self.adInCubeMediaView = nil;
    }

    // Remove adInCubeAdChoiceView
    if (self.adInCubeAdChoiceView) {
        self.adInCubeAdChoiceView.nativeAd = nil;
        [self.adInCubeAdChoiceView removeFromSuperview];
        self.adInCubeAdChoiceView = nil;
    }
    
    // Unlinking the AdinCube native ad
    [self.native unlink:self.nativeAd];
}

- (nullable NSURL *)adChoicesURL {
    return nil; // Ad choices button is implemented during the views registering.
}

- (BOOL)hasMedia {
    return NO; // Media are not supported by this adapter yet.
}

- (nullable UIView *)mediaView {
    return nil; // Media are not supported by this adapter yet.
}

#pragma mark - AdinCube native ad delegate

- (void)didLoadNative:(NSArray<AdinCubeNativeAd *> *)ads {
    self.nativeAd = [ads firstObject];
    SASMediationNativeAdInfo *nativeAdInfo = [self smartNativeAdFromAdInCubeAd:self.nativeAd];
    [self.delegate mediationNativeAdAdapter:self didLoadAdInfo:nativeAdInfo];
}

- (void)didFailToLoadNative:(NSString *)errorCode {
    NSError *error = [NSError errorWithDomain:SASAdinCubeAdapterErrorDomain code:[errorCode integerValue] userInfo:@{ NSLocalizedDescriptionKey: [NSString stringWithFormat:@"AdInCube Banner Error: %@", errorCode] }];
    [self.delegate mediationNativeAdAdapter:self didFailToLoadWithError:error noFill:[errorCode isEqualToString:SASAdinCubeAdapterNoFillErrorCode]];
}

- (void)didClickOnNative:(AdinCubeNativeAd *)nativeAd {
    [self.delegate mediationNativeAdAdapterDidReceiveAdClickedEvent:self];
}

#pragma mark - Util methods

- (SASMediationNativeAdInfo *)smartNativeAdFromAdInCubeAd:(AdinCubeNativeAd *)adInCubeNativeAd {
    // Converting the received native ad into a SASMediationNativeAdInfo object
    SASMediationNativeAdInfo *nativeAdInfo = [[SASMediationNativeAdInfo alloc] initWithTitle:adInCubeNativeAd.title];
    
    nativeAdInfo.subtitle = adInCubeNativeAd.text;
    nativeAdInfo.callToAction = adInCubeNativeAd.callToAction;
    nativeAdInfo.rating = [adInCubeNativeAd.rating floatValue];
    
    if (adInCubeNativeAd.cover) {
        nativeAdInfo.coverImage = [[SASNativeAdImage alloc] initWithURL:adInCubeNativeAd.cover.url
                                                                  width:[adInCubeNativeAd.cover.width floatValue]
                                                                 height:[adInCubeNativeAd.cover.height floatValue]];
    }
    
    if (adInCubeNativeAd.icon) {
        nativeAdInfo.icon = [[SASNativeAdImage alloc] initWithURL:adInCubeNativeAd.icon.url
                                                            width:[adInCubeNativeAd.icon.width floatValue]
                                                           height:[adInCubeNativeAd.icon.height floatValue]];
    }

    return nativeAdInfo;
}

@end

NS_ASSUME_NONNULL_END
