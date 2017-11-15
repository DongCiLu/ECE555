#include <Timer.h>

module EasyDisseminationC {

uses interface Boot;
uses interface Leds;
uses interface Timer<TMilli>;

uses interface StdControl as DisseminationControl;
uses interface DisseminationValue<uint8_t> as Value;
uses interface DisseminationUpdate<uint8_t> as Update;

uses interface SplitControl as RadioControl;

}

implementation {
	uint8_t counter;

	task void showCounter() {
		call Leds.set(counter);
	}

	event void Timer.fired() {
		if ( TOS_NODE_ID  == 2 ) {
			counter = counter + 1;
			call Update.change(&counter);
		}
	}

	event void Value.changed() {
		const uint8_t* newVal = call Value.get();
		if (TOS_NODE_ID != 2) {
			counter = *newVal;
		}
		post showCounter();
	}

	event void Boot.booted() {
		call RadioControl.start();
	}

	event void RadioControl.startDone(error_t err) {
		if (err != SUCCESS) 
		call RadioControl.start();
		else {
			call DisseminationControl.start();
			counter = 0;
			if ( TOS_NODE_ID  == 2 ) 
				call Timer.startPeriodic(2000);
		}
	}

	event void RadioControl.stopDone(error_t er) {}
}
