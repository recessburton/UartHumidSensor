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


#include "BaseStationUart.h"
#include "string.h"
#include "printf.h"

module BaseStationUartC {
	uses {
		interface Boot;
		interface Leds;

		interface Receive;
		interface SplitControl as AMControl;

	}
}

implementation {

	/*****************************************************************************************
	 * Global Variables
	 *****************************************************************************************/
	uint8_t capturedata[DATA_SIZE];

	bool busy = FALSE;

	SensorMsg * btrpkg = NULL;
	message_t pkt;

	/*****************************************************************************************
	 * Boot
	 *****************************************************************************************/ 

	event void Boot.booted() {
		call AMControl.start();
		call Leds.led0On();
	}

	event void AMControl.startDone(error_t err) {
		if(err == SUCCESS) {
			;
		}
		else {
			call AMControl.start();
		}
	}

	event void AMControl.stopDone(error_t err) {
	}
	
	event message_t* Receive.receive(message_t* msg, void* playload, uint8_t len) {
		int8_t k;

			for(k=0;k<10;k++){
				capturedata[k] = 0;
			}

		if(len == sizeof(SensorMsg)) 
		{
			SensorMsg* btrpkg = (SensorMsg*)playload;

			memcpy(capturedata, btrpkg->sensorInfo, DATA_SIZE);
 
			for(k=0;k<10;k++){
				printf("%02x ",capturedata[k]);
				btrpkg->sensorInfo[k] = 0;
			}
			printf("\n");
			printfflush();
			playload = NULL;
		}
		call Leds.led2Toggle();
		return msg;
	}

}// End 