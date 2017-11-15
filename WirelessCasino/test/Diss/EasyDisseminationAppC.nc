configuration EasyDisseminationAppC {}
implementation {

	components MainC;
	EasyDisseminationC.Boot -> MainC;
	components LedsC;
	EasyDisseminationC.Leds -> LedsC;
	components new TimerMilliC();
	EasyDisseminationC.Timer -> TimerMilliC;

	components EasyDisseminationC;
	components DisseminationC;
	EasyDisseminationC.DisseminationControl -> DisseminationC;

	components new DisseminatorC(uint8_t, 0x7777) as Diss8C;
	EasyDisseminationC.Value -> Diss8C;
	EasyDisseminationC.Update -> Diss8C;

	components ActiveMessageC;
	EasyDisseminationC.RadioControl -> ActiveMessageC;

}
