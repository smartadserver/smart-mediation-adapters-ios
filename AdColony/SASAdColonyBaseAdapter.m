//
//  SASAdColonyBaseAdapter.m
//  SmartAdServer
//
//  Created by Loïc GIRON DIT METAZ on 20/09/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import "SASAdColonyBaseAdapter.h"

NS_ASSUME_NONNULL_BEGIN

@implementation SASAdColonyBaseAdapter

- (BOOL)configureIDWithServerParameterString:(NSString *)serverParameterString error:(NSError **)error {
    // IDs are sent as a slash separated string
    NSArray *serverParameters = [serverParameterString componentsSeparatedByString:@"/"];
    
    // Invalid parameter string, the loading will be cancelled with an error
    if (serverParameters.count != 3 || ![serverParameters[2] respondsToSelector:@selector(intValue)]) {
        *error = [NSError errorWithDomain:SASAdColonyAdapterErrorDomain code:SASAdColonyAdapterErrorCode userInfo:@{ NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Invalid server parameter string: %@", serverParameterString] }];
        return NO;
    }
    
    // Extracting and converting parameters
    self.appID = serverParameters[0];
    self.zoneID = serverParameters[1];
    self.zoneType = [serverParameters[2] intValue];
    
    return YES;
}

@end

NS_ASSUME_NONNULL_END
