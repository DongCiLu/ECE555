
configuration LightSenseAppC
{ 
} 
implementation { 
  
  components LightSenseC, MainC, LedsC, new TimerMilliC(), new HamamatsuS1087ParC() as Sensor;

  LightSenseC.Boot -> MainC;
  LightSenseC.Leds -> LedsC;
  LightSenseC.Timer -> TimerMilliC;
  LightSenseC.Read -> Sensor;
}
