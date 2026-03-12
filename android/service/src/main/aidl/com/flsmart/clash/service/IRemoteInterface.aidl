// IRemoteInterface.aidl
package com.flsmart.clash.service;

import com.flsmart.clash.service.ICallbackInterface;
import com.flsmart.clash.service.IEventInterface;
import com.flsmart.clash.service.IResultInterface;
import com.flsmart.clash.service.IVoidInterface;
import com.flsmart.clash.service.models.VpnOptions;
import com.flsmart.clash.service.models.NotificationParams;

interface IRemoteInterface {
    void invokeAction(in String data, in ICallbackInterface callback);
    void quickSetup(in String initParamsString, in String setupParamsString, in ICallbackInterface callback, in IVoidInterface onStarted);
    void updateNotificationParams(in NotificationParams params);
    void startService(in VpnOptions options, in long runTime, in IResultInterface result);
    void stopService(in IResultInterface result);
    void setEventListener(in IEventInterface event);
    void setCrashlytics(in boolean enable);
    long getRunTime();
}
