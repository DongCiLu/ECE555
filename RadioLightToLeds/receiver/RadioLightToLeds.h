/*
 * Module:		Commnucation Header
 * Author:		Zheng Lu
 * Student ID:	000384662
 * Date:		Oct. 4, 2013
 */

#ifndef RADIO_LIGHT_TO_LEDS_H
#define RADIO_LIGHT_TO_LEDS_H

typedef nx_struct radio_light_msg {
  nx_uint16_t error;
  nx_uint16_t data;
} radio_light_msg_t;

enum {
  AM_RADIO_LIGHT_MSG = 7,
};

#define LightMask 3
#endif
