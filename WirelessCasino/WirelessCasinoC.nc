/*
 * Module:		Wireless Casino Implementation
 * Author:		Zheng Lu
 * Student ID:	000384662
 * Date:		Oct. 13, 2013
 */

#include "timer.h"
#include "WirelessCasino.h"

module WirelessCasinoC @safe()
{
	uses {
		interface Boot;
		interface Leds;
		interface Timer<TMilli> as sendTimer;
		interface Timer<TMilli> as comTimer;
		interface Random;

		interface SplitControl as RadioControl;

		interface StdControl as DisseminationControl;
		interface DisseminationValue<uint16_t> as Value;
		interface DisseminationUpdate<uint16_t> as Update;

		interface SplitControl as SerialControl;
		
		interface AMSend as UartSend;
		interface Packet as UartPacket;
	}
}

implementation {
	task void nodeInit(); // Initializing state of each node
	task void game(); // Main state machine
	task void uartSendResult(); // Serial report result

	uint8_t nodeType; // Type of node: Master or Slave
	uint8_t nodeState; // States of node
	uint8_t masterId; // ID of master node

	wireless_casino_msg_t rmsg, smsg; // Message payload
	uint8_t buf[SLAVECNT]; // Store bidding number

	uint8_t uartProgress; // Serial Comm Sending which result
	oscilloscope_t uartPacket; // Serial Comm Packet
	message_t uartBuf;

	uint16_t cycle;

	event void Boot.booted() {
		call RadioControl.start();
		call SerialControl.start();
	}
	event void SerialControl.startDone(error_t err) {}

	event void RadioControl.startDone(error_t err) {
		if (err != SUCCESS) 
			call RadioControl.start();
		else {
			call DisseminationControl.start();
			cycle = 0;
			uartPacket.interval = DEFAULT_INTERVAL;
			masterId = 1;
			post nodeInit();
		}
	}

	event void SerialControl.stopDone(error_t er) {}

	event void RadioControl.stopDone(error_t er) {}

	event void sendTimer.fired() {
		call Update.change((uint16_t*) &smsg);
	}

	event void comTimer.fired() {
		if (smsg.type == RD_START)
			call Leds.set(0);
		else
			post nodeInit();
	}

	event void Value.changed() {
		rmsg = *((wireless_casino_msg_t*)call Value.get());
		post game();
	}

	event void UartSend.sendDone(message_t* msg, error_t err) {
		if (err == SUCCESS)
			uartProgress = uartProgress + 1;

		if(uartProgress <= SLAVECNT + 1) 
			post uartSendResult();
	}

	task void nodeInit() {
		uint8_t i;
		cycle = cycle + 1;
		call Leds.set(0);
		for(i = 0; i < SLAVECNT; i++)
			buf[i] = 0;
		uartProgress = 1;

		if (TOS_NODE_ID == masterId) {
			nodeType = WC_MASTER;
			nodeState = MS_INIT;

			rmsg.type = LOCALHOST;
			rmsg.data = 0x00;
			post game();
		}
		else {
			nodeType = WC_SLAVE;
			nodeState = SL_IDLE;
		}
	}

	task void game() {
		switch (rmsg.type) {
			case LOCALHOST:
				/* Phase 1: Master send out start command */
				if (nodeType == WC_MASTER && \
						nodeState == MS_INIT) {
					smsg.type = RD_START;
					smsg.data = 0x00; 
					call Leds.set(7);
					call sendTimer.startOneShot(TIMEOUT);
					call comTimer.startOneShot(TIMEOUT);

					nodeState = MS_JUDG;
				}
				break;
			case RD_START:
				/* Phase 2: Slave generate and send out bidding numbers */
				if (nodeType == WC_SLAVE && \
						nodeState == SL_IDLE) {
					uint8_t id = TOS_NODE_ID;
					uint8_t biddingNum = call Random.rand16() % 6 + 1;
					smsg.type = RD_BIDDING;
					// compressing node id and bidding number together
					smsg.data = (id << BIDDBITS) | biddingNum;

					buf[0] = smsg.data; // only work for 2 nodes
					call Leds.set(smsg.data);
					call sendTimer.startOneShot(call Random.rand16() % BACKOFF + TIMEOUT);
					nodeState = SL_BIDD;
				}
				break;
			case RD_BIDDING:
				/* Phase 3: Master receive and compare bidding numbers and announce new master ID */
				if (nodeType == WC_MASTER && \
						nodeState == MS_JUDG) {
					uint8_t i;
					bool exist;
					uint8_t id = rmsg.data >> BIDDBITS;
					for (i = 0, exist = FALSE; \
							i < SLAVECNT && buf[i] != 0; i++) 
						if ((buf[i] >> BIDDBITS) == id)
							exist = TRUE; // already exist, discard

					if (exist == FALSE)
						buf[i] = rmsg.data; // not exist, store

					// bidding numbers fully collected
					if (i == SLAVECNT - 1) {
						uint8_t max;
						for (i = 0, max = 0; i < SLAVECNT; i++)
							if ((buf[i] & BIDDMASK) > max) {
								// first arrived bidding has higher priority 
								max = buf[i] & BIDDMASK;
								smsg.data = buf[i];
							}

						smsg.type = RD_ANNOUNCE;
						call sendTimer.startOneShot(TIMEOUT);
						call comTimer.startOneShot(TIMEOUT + WAITNET);
						if (TOS_NODE_ID == 1)
							post uartSendResult();

						nodeState = MS_INIT;
						masterId = smsg.data >> BIDDBITS;
						call Leds.set(max);
					}
				}
				break;
			case RD_ANNOUNCE:
				/* Phase 4: Slave receive announcements and starting new rounds */
				if (nodeType == WC_SLAVE && \
						nodeState == SL_BIDD) {
					buf[1] = rmsg.data; //only work for 2 nodes
					call comTimer.startOneShot(WAITNET);
					if (TOS_NODE_ID == 1)
						post uartSendResult();

					nodeState = SL_IDLE;
					masterId = rmsg.data >> BIDDBITS;
				}
				break;
		}
	}

	task void uartSendResult() {
		uint8_t i;

		uartPacket.readings = 7; // master have max bidding number 
		for (i = 0; i < SLAVECNT; i++)
			if (buf[i] >> BIDDBITS == uartProgress)
				uartPacket.readings = buf[i] & BIDDMASK;

		uartPacket.id = uartProgress;
		uartPacket.count = cycle;
		memcpy(call UartSend.getPayload(&uartBuf, sizeof(uartPacket)), &uartPacket, sizeof uartPacket);
		if (call UartSend.send(AM_BROADCAST_ADDR, &uartBuf, sizeof uartPacket) != SUCCESS) {
			post uartSendResult();
		}
	}

}

