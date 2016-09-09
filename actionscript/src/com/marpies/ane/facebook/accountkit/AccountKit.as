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

package com.marpies.ane.facebook.accountkit {

    import flash.events.StatusEvent;

    CONFIG::ane {
        import flash.external.ExtensionContext;
    }

    import flash.system.Capabilities;
    import flash.utils.Dictionary;

    public class AccountKit {

        private static const TAG:String = "[AccountKit]";
        private static const EXTENSION_ID:String = "com.marpies.ane.facebook.accountkit";
        private static const iOS:Boolean = Capabilities.manufacturer.indexOf( "iOS" ) > -1;
        private static const ANDROID:Boolean = Capabilities.manufacturer.indexOf( "Android" ) > -1;

        CONFIG::ane {
            private static var mContext:ExtensionContext;
        }

        /* Event codes */
        private static const INIT:String = "init";

        /* Callbacks */
        private static var mCallbackMap:Dictionary;
        private static var mCallbackIdCounter:int;
        private static var mInitCallback:Function;

        /* Misc */
        private static var mInitialized:Boolean;
        private static var mLogEnabled:Boolean;

        /**
         * @private
         * Do not use. AccountKit is a static class.
         */
        public function AccountKit() {
            throw Error( "AccountKit is static class." );
        }

        /**
         *
         *
         * Public API
         *
         *
         */

        /**
         * Initializes extension context.
         *
         * @param responseType The type of response that will be returned from a login.
         * @param initCallback Function that will be called when AccountKit SDK is initialized.
         * The function is expected to have the following signature:
         * <listing version="3.0">
         * function callback():void {
         *
         * };
         * </listing>
         * @param showLogs Set to <code>true</code> to show extension log messages.
         *
         * @return <code>true</code> if the extension context was created, <code>false</code> otherwise
         *
         * @see com.marpies.ane.facebook.accountkit.AKResponseType
         */
        public static function init( responseType:String, initCallback:Function = null, showLogs:Boolean = false ):Boolean {
            if( !isSupported ) return false;
            if( mInitialized ) return true;

            mLogEnabled = showLogs;

            /* Initialize context */
            if( !initExtensionContext() ) {
                log( "Error creating extension context for " + EXTENSION_ID );
                return false;
            }
            /* Listen for native library events */
            CONFIG::ane {
                mContext.addEventListener( StatusEvent.STATUS, onStatus );
            }

            mCallbackMap = new Dictionary();

            /* Call init */
            CONFIG::ane {
                if( !AKResponseType.isValid( responseType ) )
                    throw new ArgumentError( "Parameter responseType must be one of the values defined in AKResponseType class." );
                mInitCallback = initCallback;
                mContext.call( "init", responseType, showLogs );
            }

            mInitialized = true;
            return true;
        }

        /**
         * Disposes native extension context.
         */
        public static function dispose():void {
            if( !isSupported ) return;
            validateExtensionContext();


            CONFIG::ane {
                mContext.removeEventListener( StatusEvent.STATUS, onStatus );
                mContext.dispose();
                mContext = null;
            }

            mInitialized = false;
        }

        /**
         *
         *
         * Getters / Setters
         *
         *
         */

        /**
         * Extension version.
         */
        public static function get version():String {
            return "1.0.0";
        }

        /**
         * Supported on iOS and Android.
         */
        public static function get isSupported():Boolean {
            return iOS || ANDROID;
        }

        /**
         *
         *
         * Private API
         *
         *
         */

        private static function onStatus( event:StatusEvent ):void {
            switch( event.code ) {
                case INIT:
                    if( mInitCallback !== null ) {
                        mInitCallback();
                        mInitCallback = null;
                    }
                    return;
            }
        }

        /**
         * Initializes extension context.
         * @return <code>true</code> if initialized successfully, <code>false</code> otherwise.
         */
        private static function initExtensionContext():Boolean {
            CONFIG::ane {
                if( mContext === null ) {
                    mContext = ExtensionContext.createExtensionContext( EXTENSION_ID, null );
                }
                return mContext !== null;
            }
            return false;
        }

        /**
         * Registers given callback and generates ID which is used to look the callback up when it is time to call it.
         * @param callback Function to register.
         * @return ID of the callback.
         */
        private static function registerCallback( callback:Function ):int {
            if( callback == null ) return -1;

            mCallbackMap[mCallbackIdCounter] = callback;
            return mCallbackIdCounter++;
        }

        /**
         * Gets registered callback with given ID.
         * @param callbackID ID of the callback to retrieve.
         * @return Callback registered with given ID, or <code>null</code> if no such callback exists.
         */
        private static function getCallback( callbackID:int ):Function {
            if( callbackID == -1 || !(callbackID in mCallbackMap) ) return null;
            return mCallbackMap[callbackID];
        }

        /**
         * Unregisters callback with given ID.
         * @param callbackID ID of the callback to unregister.
         */
        private static function unregisterCallback( callbackID:int ):void {
            if( callbackID in mCallbackMap ) {
                delete mCallbackMap[callbackID];
            }
        }

        private static function validateExtensionContext():void {
            CONFIG::ane {
                if( !mContext ) throw new Error( "AccountKit extension was not initialized. Call init() first." );
            }
        }

        private static function log( message:String ):void {
            if( mLogEnabled ) {
                trace( TAG, message );
            }
        }

    }
}