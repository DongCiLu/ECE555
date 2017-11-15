#include "Timer.h"

module LightSensC
{
  uses {
    interface Boot;
    interface Leds;
    interface Timer<TMilli>;
    interface Read<uint16_t>;
  }
}
implementation
{
  // sampling frequency in binary milliseconds
  #define SAMPLING_FREQUENCY 100
  
  event void Boot.booted() {
    call Timer.startPeriodic(SAMPLING_FREQUENCY);
  }

  event void Timer.fired() 
  {
    call Read.read();
  }

  event void Read.readDone(error_t result, uint16_t data) 
  {
    if (result == SUCCESS){
        call Leds.set(data >> 3);
    }
  }
}
