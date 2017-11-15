/*
 * Module:		Bidding & Commnucation Header
 * Author:		Zheng Lu
 * Student ID:	000384662
 * Date:		Oct. 13, 2013
 */

#ifndef WIRELESS_CASINO_H
#define WIRELESS_CASINO_H

#define TIMEOUT 4000
#define BACKOFF 1000
#define WAITNET 1000

#define SLAVECNT 2

/* high 4 bits is slave id, low 4 bits is bidding number */
#define BIDDMASK 0x0F 
#define BIDDBITS 4

/* serial port packet format */
#define DEFAULT_INTERVAL 256
typedef nx_struct oscilloscope {
	nx_uint16_t version;
	nx_uint16_t interval;
	nx_uint16_t id;
	nx_uint16_t count;
	nx_uint16_t readings;
} oscilloscope_t;

typedef struct wireless_casino_msg {
  uint8_t type;
  uint8_t data;
} wireless_casino_msg_t;

enum {
  WIRELESS_CASINO_DSID = 0x7777,
  WIRELESS_CASINO_SID = 0x93,
};

// state of sensors
enum {
	WC_MASTER = 10,
	WC_SLAVE = 11,
};

// message type
enum {
	LOCALHOST = 20, /* data: NULL */
	RD_START = 21, /* data: NULL */
	RD_BIDDING = 22, /* data: bidding number */
	RD_ANNOUNCE = 23, /* data: winner id */
};

// state of master
enum {
	MS_INIT = 30,
	MS_JUDG = 31,
};

// state of slave
enum {
	SL_IDLE = 40,
	SL_BIDD = 41,
};

#endif
