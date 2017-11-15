/*
 * Module:		Receiver Implementation
 * Author:		Zheng Lu
 * Student ID:	000384662
 * Date:		Oct. 4, 2013
 */

#include "RadioLightToLeds.h"

module RadioLightToLedsReceiverC @safe(){
	uses{
		interface Leds;
		interface Boot;
		interface Receive;
		interface SplitControl as RadioControl;
	}
}

implementation{

	event void Boot.booted(){
		call RadioControl.start();
	}

	event void RadioControl.startDone(error_t err) {}
    event void RadioControl.stopDone(error_t err) {}

	event message_t* Receive.receive(message_t* bufPtr,
				 void* payload, uint8_t len) {
	  call Leds.led1Toggle();
	  if (len != sizeof(radio_light_msg_t)) {return bufPtr;}
	  else {
		radio_light_msg_t* rsm = (radio_light_msg_t*)payload;
		uint16_t val = rsm->data;
		call Leds.set(val >> LightMask); // filter noise in lowest bits.
		return bufPtr;
	  }
	}

}
