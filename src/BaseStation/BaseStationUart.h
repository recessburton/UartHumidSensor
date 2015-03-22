#ifndef  BASE_STATION_UART__
#define  BASE_STATION_UART__
enum{
  DATA_SIZE = 17, 
};

typedef nx_struct SensorMsg {
	nx_uint8_t sensorInfo[DATA_SIZE];
}SensorMsg;



enum {
  AM_SENSOR_MSG = 218,
  AM_CONTROL_MSG = 103,
};


#endif
