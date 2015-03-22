#ifndef  UART_HUMID_SENSOR__
#define  UART_HUMID_SENSOR__
enum{
  DATA_SIZE = 17, // 17 字节，具体数据格式见：传感器输出数据格式.odt
};

typedef nx_struct SensorMsg {
	nx_uint8_t sensorInfo[17];
}SensorMsg;

enum {
  AM_SENSOR_MSG = 218,
  AM_CONTROL_MSG = 103,
};

#endif     
