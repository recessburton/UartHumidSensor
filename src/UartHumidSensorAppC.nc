configuration UartHumidSensorAppC {
}
implementation {
	components MainC, UartHumidSensorC as App, LedsC;

	MainC.Boot<-App;
	App.Leds->LedsC;

	// Msp430Uart0C is uart0 of MSP430F1611, pin 2 (RX) and 4 (TX) of 10 pin Expansion in telosb
	// Msp430Uart1C is uart1 of MSP430F1611, converted to USB in telosb
	//Msp430UartxC implements 3 import interfaces: Resource, UartStream, Msp430UartConfigure
	components new Msp430Uart0C() as UartC;
	App.Resource->UartC.Resource;
	App.UartStream->UartC.UartStream;
	App.Msp430UartConfigure<-UartC.Msp430UartConfigure;

}