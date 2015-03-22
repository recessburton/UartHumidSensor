/*
 * Copyright (C)  ytc recessburton@gmail.com 2015-3-22
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

#define NEW_PRINTF_SEMANTICS

configuration BaseStationUartAppC {
}

implementation {
	components MainC, BaseStationUartC as App, LedsC;
	components ActiveMessageC;
 	components new AMReceiverC(AM_SENSOR_MSG);
 	
 	components PrintfC;
	components SerialStartC;

	MainC.Boot<-App;
	App.Leds->LedsC;
	
	App.AMControl -> ActiveMessageC;
	App.Receive -> AMReceiverC;

}