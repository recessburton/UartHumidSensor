/*
 * Copyright (C)  ytc recessburton@gmail.com 2015-3-20
 *

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 * ========================================================================
 */

configuration UartHumidSensorAppC {
}
implementation {
	components MainC, UartHumidSensorC as App, LedsC;
	components ActiveMessageC;
 	components new AMSenderC(AM_SENSOR_MSG);

	MainC.Boot<-App;
	App.Leds->LedsC;

	App.AMControl -> ActiveMessageC;
	App.AMSend -> AMSenderC;
	App.Packet -> AMSenderC;

	components new Msp430Uart1C() as UartC;
	App.Resource->UartC.Resource;
	App.UartStream->UartC.UartStream;
	App.Msp430UartConfigure<-UartC.Msp430UartConfigure;

}