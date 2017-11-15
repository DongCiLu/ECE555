/*
 * Module:		Sender Configuration
 * Author:		Zheng Lu
 * Student ID:	000384662
 * Date:		Oct. 4, 2013
 */

#include "RadioLightToLeds.h"

configuration RadioLightToLedsSenderAppC {}
implementation {
  components MainC, RadioLightToLedsSenderC as App, LedsC;
  components ActiveMessageC;
  components new HamamatsuS1087ParC() as Sensor;
  components new AMSenderC(AM_RADIO_LIGHT_MSG);
  components new TimerMilliC();
  
  App.Boot -> MainC.Boot;
  App.AMSend -> AMSenderC;
  App.Packet -> AMSenderC;
  App.Read -> Sensor;
  App.MilliTimer -> TimerMilliC;
  App.RadioControl -> ActiveMessageC;
  App.Leds -> LedsC;
}
