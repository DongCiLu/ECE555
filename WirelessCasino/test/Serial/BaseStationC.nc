configuration SerialAppC {
}
implementation {
  components MainC, SerialC, LedsC;
  components SerialActiveMessageC as Serial;
  
  MainC.Boot <- SerialC;

  SerialC.SerialControl -> Serial;
  
  SerialC.UartSend -> Serial;
  SerialC.UartReceive -> Serial.Receive;
  SerialC.UartPacket -> Serial;
  SerialC.UartAMPacket -> Serial;
}
