/*
 * Module:		Wireless Casino Configuration
 * Author:		Zheng Lu
 * Student ID:	000384662
 * Date:		Oct. 13, 2013
 */

#include "WirelessCasino.h"

configuration WirelessCasinoAppC {}
implementation {

	components WirelessCasinoC, MainC, LedsC, ActiveMessageC;
	components new TimerMilliC() as Timer0;
	components new TimerMilliC() as Timer1;
	WirelessCasinoC.Boot -> MainC;
	WirelessCasinoC.Leds -> LedsC;
	WirelessCasinoC.sendTimer -> Timer0;
	WirelessCasinoC.comTimer -> Timer1;
	WirelessCasinoC.RadioControl -> ActiveMessageC;

	components RandomC;
	WirelessCasinoC.Random -> RandomC;

	components DisseminationC;
	WirelessCasinoC.DisseminationControl -> DisseminationC;

	components new DisseminatorC(uint16_t, WIRELESS_CASINO_DSID) as DissC;
	WirelessCasinoC.Value -> DissC;
	WirelessCasinoC.Update -> DissC;

	components SerialActiveMessageC as Serial;
	WirelessCasinoC.SerialControl -> Serial;
	WirelessCasinoC.UartSend -> Serial.AMSend[WIRELESS_CASINO_SID];
	WirelessCasinoC.UartPacket -> Serial;
}
