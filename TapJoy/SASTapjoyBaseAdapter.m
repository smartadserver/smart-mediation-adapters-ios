//
//  SASTapjoyBaseAdapter.m
//  SmartAdServer
//
//  Created by Loïc GIRON DIT METAZ on 24/09/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import "SASTapjoyBaseAdapter.h"

NS_ASSUME_NONNULL_BEGIN

@implementation SASTapjoyBaseAdapter

#pragma mark - Object lifecycle

- (void)dealloc {
    // Unregistering Tapjoy connection events
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    if (self = [super init]) {
        // Registering for Tapjoy connection events
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(tapjoyConnectSuccess:)
                                                     name:TJC_CONNECT_SUCCESS
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(tapjoyConnectFail:)
                                                     name:TJC_CONNECT_FAILED
                                                   object:nil];
    }
    return self;
}

#pragma mark - Overridable methods

- (void)connectionDidSucceed {
    NSAssert(NO, @"-[SASTapjoyBaseAdapter connectionDidSucceed] must be overriden by subclasses!");
}

- (void)connectionDidFailWithError:(NSError *)error {
    NSAssert(NO, @"-[SASTapjoyBaseAdapter connectionDidFailWithError:] must be overriden by subclasses!");
}

#pragma mark - Base methods

- (BOOL)configureIDWithServerParameterString:(NSString *)serverParameterString error:(NSError **)error {
    // IDs are sent as a slash separated string
    NSArray *serverParameters = [serverParameterString componentsSeparatedByString:@"/"];
    
    // Invalid parameter string, the loading will be cancelled with an error
    if (serverParameters.count != 2 || ![serverParameters[0] isKindOfClass:[NSString class]] || ![serverParameters[1] isKindOfClass:[NSString class]]) {
        *error = [NSError errorWithDomain:SASTapjoyAdapterErrorDomain code:SASTapjoyAdapterErrorCodeInvalidParameterString userInfo:@{ NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Invalid server parameter string: %@", serverParameterString] }];
        return NO;
    }
    
    // Extracting and converting parameters
    self.applicationID = serverParameters[0];
    self.placementName = serverParameters[1];
    
    return YES;
}

- (void)configureGDPRWithClientParameters:(NSDictionary *)clientParameters {
    BOOL gdprApplies = [[clientParameters objectForKey:SASMediationClientParameterGDPRApplies] boolValue];
    NSString *gdprConsent = [clientParameters objectForKey:SASMediationClientParameterGDPRConsent];
    
    [Tapjoy subjectToGDPR:gdprApplies];
    if (gdprConsent != nil) {
        [Tapjoy setUserConsent:gdprConsent];
    }
}

- (void)connectTapjoySDK {
    // The Tapjoy SDK must be connected before any ad call.
    if ([Tapjoy isConnected]) {
        [self connectionDidSucceed];
    } else {
        [Tapjoy connect:self.applicationID];
    }
}

#pragma mark - Tapjoy events

- (void)tapjoyConnectSuccess:(NSNotification *)notification {
    [self connectionDidSucceed];
}


- (void)tapjoyConnectFail:(NSNotification *)notification {
    NSError *error = [NSError errorWithDomain:SASTapjoyAdapterErrorDomain code:SASTapjoyAdapterErrorCodeUnableToConnect userInfo:@{ NSLocalizedDescriptionKey: @"Unable to connect Tapjoy SDK" }];
    [self connectionDidFailWithError:error];
}

@end

NS_ASSUME_NONNULL_END
