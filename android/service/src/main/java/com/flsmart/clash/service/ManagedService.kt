package com.flsmart.clash.service

import android.app.Service
import com.flsmart.clash.common.BroadcastAction
import com.flsmart.clash.common.GlobalState
import com.flsmart.clash.common.sendBroadcast

interface ManagedService {
    fun start()

    fun stop()
}

internal fun Service.notifyVpnStartRequested() {
    GlobalState.log("VPN start requested")
    BroadcastAction.VPN_START_REQUESTED.sendBroadcast()
}

internal fun Service.notifyVpnRevoked() {
    GlobalState.log("VPN permission revoked")
    BroadcastAction.VPN_REVOKED.sendBroadcast()
}
