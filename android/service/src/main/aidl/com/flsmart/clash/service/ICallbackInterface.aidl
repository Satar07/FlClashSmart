// ICallbackInterface.aidl
package com.flsmart.clash.service;

import com.flsmart.clash.service.IAckInterface;

interface ICallbackInterface {
    oneway void onResult(in byte[] data,in boolean isSuccess, in IAckInterface ack);
}
