/*
 * Module:		Receiver Configuration
 * Author:		Zheng Lu
 * Student ID:	000384662
 * Date:		Oct. 4, 2013
 */

#include "RadioLightToLeds.h"

configuration RadioLightToLedsReceiverAppC {}
implementation {
  components MainC, RadioLightToLedsReceiverC as App, LedsC;
  components ActiveMessageC;
  components new AMReceiverC(AM_RADIO_LIGHT_MSG);
  
  App.Boot -> MainC.Boot;
  App.Receive -> AMReceiverC;
  App.RadioControl -> ActiveMessageC;
  App.Leds -> LedsC;
}
