/*
 * Module:		Sender Implementation
 * Author:		Zheng Lu
 * Student ID:	000384662
 * Date:		Oct. 4, 2013
 */

#include "Timer.h"
#include "RadioLightToLeds.h"

module RadioLightToLedsSenderC @safe(){
  uses {
    interface Leds;
    interface Boot;
    interface AMSend;
    interface Timer<TMilli> as MilliTimer;
    interface Packet;
    interface Read<uint16_t>;
    interface SplitControl as RadioControl;
  }
}
implementation {

  message_t packet;
  bool locked = FALSE;
   
  event void Boot.booted() {
    call RadioControl.start();
  }

  event void RadioControl.startDone(error_t err) {
    if (err == SUCCESS) {
      call MilliTimer.startPeriodic(250);
    }
  }
  event void RadioControl.stopDone(error_t err) {}
  
  event void MilliTimer.fired() {
    call Read.read();
  }

  event void Read.readDone(error_t result, uint16_t data) {
    if (locked) {
      return;
    }
    else {
      radio_light_msg_t* rsm;

      rsm = (radio_light_msg_t*)call Packet.getPayload(&packet, sizeof(radio_light_msg_t));
      if (rsm == NULL) {
	return;
      }
      rsm->error = result;
      rsm->data = data;
      if (call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(radio_light_msg_t)) == SUCCESS) {
		locked = TRUE;
		call Leds.set(data >> LightMask); // filter noise in lowest bits.
      }
    }
  }

  event void AMSend.sendDone(message_t* bufPtr, error_t error) {
    if (&packet == bufPtr) {
      locked = FALSE;
    }
  }
}
