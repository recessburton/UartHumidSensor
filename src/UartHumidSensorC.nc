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


#include "UartHumidSensor.h"

module UartHumidSensorC {
	provides {
		interface Msp430UartConfigure;
	}
	uses {
		interface Boot;
		interface Leds;

		// Uart
		interface Resource;
		interface UartStream;

	}
}

implementation {

	/*****************************************************************************************
	 * Global Variables
	 *****************************************************************************************/
	uint8_t capturedata[DATA_SIZE];

	/*****************************************************************************************
	 * Task & function declaration
	 *****************************************************************************************/
	task void requestUART();
	task void releaseUART();

	/*****************************************************************************************
	 * Boot
	 *****************************************************************************************/ 

	event void Boot.booted() {
		call Leds.led0On();
		call Leds.led1On();
		call Leds.led2On();
		post requestUART();
	}

	/*****************************************************************************************
	 * Uart Configuration
	 *****************************************************************************************/ 

	msp430_uart_union_config_t msp430_uart_config = {{ ubr : UBR_1MHZ_115200, // Baud rate (use enum msp430_uart_rate_t in msp430usart.h for predefined rates)
			umctl : UMCTL_1MHZ_115200, // Modulation (use enum msp430_uart_rate_t in msp430usart.h for predefined rates)
			ssel : 0x02, // Clock source (00=UCLKI; 01=ACLK; 10=SMCLK; 11=SMCLK)
			pena : 0, // Parity enable (0=disabled; 1=enabled)
			pev : 0, // Parity select (0=odd; 1=even)
			spb : 0, // Stop bits (0=one stop bit; 1=two stop bits)
			clen : 1, // Character length (0=7-bit data; 1=8-bit data)
			listen : 0, // Listen enable (0=disabled; 1=enabled, feed tx back to receiver)
			mm : 0, // Multiprocessor mode (0=idle-line protocol; 1=address-bit protocol)
			ckpl : 0, // Clock polarity (0=normal; 1=inverted)
			urxse : 0, // Receive start-edge detection (0=disabled; 1=enabled)
			urxeie : 1, // Erroneous-character receive (0=rejected; 1=recieved and URXIFGx set)
			urxwie : 0, // Wake-up interrupt-enable (0=all characters set URXIFGx; 1=only address sets URXIFGx)
			utxe : 1, // 1:enable tx module
			urxe : 1	// 1:enable rx module   

	}};

	async command msp430_uart_union_config_t * Msp430UartConfigure.getConfig() {
		return & msp430_uart_config;
	}

	/*****************************************************************************************
	 * Uart Usage
	 *****************************************************************************************/ 

	task void requestUART() {
		call Resource.request();	// Request UART Resource
	}

	task void releaseUART() {
		call Resource.release();
	}

	event void Resource.granted() {

		call UartStream.receive(capturedata, DATA_SIZE);
	}

	async event void UartStream.sendDone(uint8_t * buf, uint16_t len,
			error_t error) {
		if(error == SUCCESS) {
			call Leds.led0Toggle();
			call UartStream.receive(capturedata, DATA_SIZE); // Receive data message
		}
		else {
			call UartStream.receive(capturedata, DATA_SIZE);
		}
	}

	async event void UartStream.receivedByte(uint8_t byte) {

	}

	async event void UartStream.receiveDone(uint8_t * buf, uint16_t len,
			error_t error) {
		error_t result;
		if(len == DATA_SIZE) {
			call Leds.led2Toggle();
			memcpy(capturedata, buf, DATA_SIZE);
			capturedata[0] += 0x11;
			capturedata[1] += 0x11;
			result = call UartStream.send(capturedata, DATA_SIZE);
		}
		else {
			call UartStream.receive(capturedata, DATA_SIZE);
		}
	}

}// End 