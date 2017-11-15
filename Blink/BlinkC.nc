/*
 * Author:	Zheng Lu
 * Student ID:	000384662
 * Email:	zlu12@utk.edu
 */

#include "Timer.h"

module BlinkC @safe()
{
  uses interface Timer<TMilli> as Timer0;
  uses interface Leds;
  uses interface Boot;
}
implementation
{
  uint8_t cnt = 0;
  // we split on cycle into 4 stage, to implement the effect of "higher bits on - off - lower bits on - off"
  uint8_t stage = 0; 

  event void Boot.booted()
  {
    call Timer0.startPeriodic( 500 );
  }

  event void Timer0.fired()
  {
    stage++;
	switch(stage % 4)
	{
		case (1) :
			cnt ++;
			call Leds.set(cnt>>3); // higher 3 bits
			break;
		case (3) :
			call Leds.set(cnt); // lower 3 bits
			break;
		default :
			call Leds.set(0); // black pauses
			break;
	}
  }
}

