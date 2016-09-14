/*
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

package com.marpies.ane.facebook.accountkit.functions;

import android.support.annotation.Nullable;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREObject;
import com.facebook.accountkit.AccountKit;
import com.facebook.accountkit.AccountKitError;
import com.facebook.accountkit.AccountPreferences;
import com.marpies.ane.facebook.accountkit.data.AccountKitEvent;
import com.marpies.ane.facebook.accountkit.utils.AIR;
import com.marpies.ane.facebook.accountkit.utils.FREObjectUtils;
import com.marpies.ane.facebook.accountkit.utils.JSONUtils;
import com.marpies.ane.facebook.accountkit.utils.StringUtils;
import org.json.JSONObject;

public class DeletePreferenceFunction extends BaseFunction {

	@Override
	public FREObject call( FREContext context, FREObject[] args ) {
		super.call( context, args );

		AIR.log( "AccountKit::deletePreference" );
		final int callbackId = FREObjectUtils.getInt( args[1] );

		/* User is not logged in, cannot delete preference */
		if( AccountKit.getCurrentAccessToken() == null ) {
			dispatchError( callbackId, "User is not logged in, cannot delete preference." );
			return null;
		}

		String prefKey = FREObjectUtils.getString( args[0] );
		AccountKit.getAccountPreferences().deletePreference( prefKey, new AccountPreferences.OnDeletePreferenceListener() {
			@Override
			public void onDeletePreference( String key, @Nullable AccountKitError accountKitError ) {
				if( accountKitError != null ) {
					dispatchError( callbackId, accountKitError.getErrorType().getMessage() );
				} else {
					AIR.log( "AccountKit | successfully deleted preference" );
					JSONObject response = new JSONObject();
					JSONUtils.addToJSON( response, "callbackId", callbackId );
					JSONUtils.addToJSON( response, "key", key );
					AIR.dispatchEvent( AccountKitEvent.DELETE_PREFERENCE, response.toString() );
				}
			}
		} );

		return null;
	}

	private void dispatchError( int callbackId, String message ) {
		AIR.log( "AccountKit | failed to delete preference: " + message );
		AIR.dispatchEvent( AccountKitEvent.DELETE_PREFERENCE, StringUtils.getEventErrorJSON( callbackId, message ) );
	}

}

