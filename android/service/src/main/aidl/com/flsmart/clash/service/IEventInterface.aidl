// IEventInterface.aidl
package com.flsmart.clash.service;

import com.flsmart.clash.service.IAckInterface;

interface IEventInterface {
    oneway void onEvent(in String id, in byte[] data,in boolean isSuccess, in IAckInterface ack);
}
