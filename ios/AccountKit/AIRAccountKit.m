/**
 * Copyright 2016 Marcel Piestansky (http://marpies.com)
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "AIRAccountKit.h"
#import "Functions/InitFunction.h"
#import "Functions/LoginFunction.h"
#import "Functions/GetAccessTokenFunction.h"
#import "Functions/GetSdkVersionFunction.h"
#import "Functions/LogoutFunction.h"
#import "Functions/GetCurrentAccountFunction.h"
#import "Functions/IsSupportedFunction.h"
#import "Functions/SetPreferenceFunction.h"
#import "Functions/LoadPreferenceFunction.h"
#import "Functions/LoadPreferencesFunction.h"
#import "Functions/DeletePreferenceFunction.h"

static BOOL AIRAccountKitLogEnabled = NO;
FREContext AIRAccountKitExtContext = nil;
static AIRAccountKit* AIRAccountKitSharedInstance = nil;

@implementation AIRAccountKit

@synthesize helper;

+ (nonnull instancetype) sharedInstance {
    if( AIRAccountKitSharedInstance == nil ) {
        AIRAccountKitSharedInstance = [[AIRAccountKit alloc] init];
    }
    return AIRAccountKitSharedInstance;
}

+ (void) dispatchEvent:(const NSString*) eventName {
    [self dispatchEvent:eventName withMessage:@""];
}

+ (void) dispatchEvent:(const NSString*) eventName withMessage:(NSString*) message {
    NSString* messageText = message ? message : @"";
    FREDispatchStatusEventAsync( AIRAccountKitExtContext, (const uint8_t*) [eventName UTF8String], (const uint8_t*) [messageText UTF8String] );
}

+ (void) log:(const NSString*) message {
    if( AIRAccountKitLogEnabled ) {
        NSLog( @"[iOS-AccountKit] %@", message );
    }
}

+ (void) showLogs:(BOOL) showLogs {
    AIRAccountKitLogEnabled = showLogs;
}

@end

/**
 *
 *
 * Context initialization
 *
 *
 **/
FRENamedFunction airAccountKitExtFunctions[] = {
    { (const uint8_t*) "init",              0, fbak_init },
    { (const uint8_t*) "login",             0, fbak_login },
    { (const uint8_t*) "getAccessToken",    0, fbak_getAccessToken },
    { (const uint8_t*) "getSdkVersion",     0, fbak_getSdkVersion },
    { (const uint8_t*) "getCurrentAccount", 0, fbak_getCurrentAccount },
    { (const uint8_t*) "logout",            0, fbak_logout },
    { (const uint8_t*) "isSupported",       0, fbak_isSupported },
    { (const uint8_t*) "setPreference",     0, fbak_setPreference },
    { (const uint8_t*) "deletePreference",  0, fbak_deletePreference },
    { (const uint8_t*) "loadPreference",    0, fbak_loadPreference },
    { (const uint8_t*) "loadPreferences",   0, fbak_loadPreferences },
};

void AccountKitContextInitializer( void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctionsToSet, const FRENamedFunction** functionsToSet ) {
    *numFunctionsToSet = sizeof( airAccountKitExtFunctions ) / sizeof( FRENamedFunction );
    
    *functionsToSet = airAccountKitExtFunctions;
    
    AIRAccountKitExtContext = ctx;
}

void AccountKitContextFinalizer( FREContext ctx ) { }

void AccountKitInitializer( void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet ) {
    *extDataToSet = NULL;
    *ctxInitializerToSet = &AccountKitContextInitializer;
    *ctxFinalizerToSet = &AccountKitContextFinalizer;
}

void AccountKitFinalizer( void* extData ) { }







