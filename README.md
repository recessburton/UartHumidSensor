Author:YTC 
Mail:recessburton@gmail.com
Created Time: 2015.3.20

Description：
	TinyOS TelosB RS485土壤湿度传感器读写程序,需转成串口，利用了uart读写程序.
	node程序通过六合一转换板将传感器的RS485转成串口，通过uart接收，并发送至AM.
	BaseStation程序通过AM接收数据，并printf至屏幕上，PC可以通过java PrintfClinet来显示.
	c_conf PC程序用来设置并接收传感器数据.不通过telosb，直接用六合一板将RS485转成USB，根据相应提示操作.
	


Known Bugs: 
		1.c_conf 程序的设置功能缺陷.操作成功几率非常低.

