/*
 * Author:	Zheng Lu
 * Student ID:	000384662
 * Email:	zlu12@utk.edu
 */

configuration BlinkAppC
{
}
implementation
{
  components MainC, BlinkC, LedsC;
  components new TimerMilliC() as Timer0;


  BlinkC -> MainC.Boot;

  BlinkC.Timer0 -> Timer0;
  BlinkC.Leds -> LedsC;
}

