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

#import "SetPreferenceFunction.h"
#import <AIRExtHelpers/MPFREObjectUtils.h>
#import "AIRAccountKit.h"

FREObject fbak_setPreference( FREContext context, void* functionData, uint32_t argc, FREObject argv[] ) {
    [AIRAccountKit log:@"AccountKit::setPreference"];
    NSString* prefKey = [MPFREObjectUtils getNSString:argv[0]];
    NSString* prefValue = [MPFREObjectUtils getNSString:argv[1]];
    int callbackId = [MPFREObjectUtils getInt:argv[2]];
    [[[AIRAccountKit sharedInstance] helper] setPreference:prefKey value:prefValue callbackId:callbackId];
    return nil;
}