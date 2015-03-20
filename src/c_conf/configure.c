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

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>
#include <malloc.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <termios.h>
#define max_buffer_size 100 /*定义缓冲区最大宽度*/

/*******************************************/
int fd; /*定义设备文件描述符*/
int flag_close;
int open_serial(int k)
{
	if(k==0) /*串口选择*/
	{
		fd = open("/dev/ttyUSB0",O_RDWR|O_NOCTTY); /*读写方式打开串口*/
		perror("open /dev/ttyUSB0");
	}
	else
	{
		fd = open("/dev/ttyUSB1",O_RDWR|O_NOCTTY);
		perror("open /dev/ttyUSB1");
	}
	if(fd == -1) /*打开失败*/
		return -1;
	else
		return 0;
}

/*传感器生产商提供的计算CRC16校验码函数，位于数据包最末尾两个字节
 * 输入参数1：snd，待校验的字节数组名
 * 输入参数2：num，待校验的字节总数（包括CRC校验的2个字节）
 * 函数返回值：校验失败时返回非0值。校验成功返回0。
 * */
unsigned int calc_crc16 (unsigned char *snd, unsigned char num)
{
	unsigned char i, j;
	unsigned int c,crc=0xFFFF;
	for(i = 0; i < num; i ++)
	{
		c = snd[i] & 0x00FF;
		crc ^= c;
		for(j = 0;j < 8; j ++)
		{
			if (crc & 0x0001)
			{
				crc>>=1;
				crc^=0xA001;
			}
			else
			{
				crc>>=1;
			}
		}
	}
	return(crc);
}


/********************************************************************/
int main(int argc, char *argv[ ] )
{
		unsigned char sbuf[8];		/*待发送的内容*/
		unsigned char crc_ready[6]; /*待校验字符串*/
		unsigned char constru;
		unsigned char hd[max_buffer_size],*rbuf;
		unsigned int vol,curr,index=0,crc_value=0;
		rbuf=hd;
		int sfd,retv,i,output_interval,function;
		struct termios option;
    
    	int length=sizeof(sbuf);/*发送缓冲区数据宽度*/
    	/*******************************************************************/
    	open_serial(0); /*打开串口0*/
    	/*******************************************************************/
    	tcgetattr(fd,&option);
    	cfmakeraw(&option);
    	/*****************************************************************/
    	cfsetispeed(&option,B9600); /*波特率设置为9600bps*/
    	cfsetospeed(&option,B9600);
    	/*******************************************************************/
    	tcsetattr(fd,TCSANOW,&option);

    	printf("选择需要的操作 1.设置读取时间间隔   2.读湿度值：");
		scanf("%d",&function);
		if(function<1 || function>2)
		{
			perror("输入错误，再见！");
			return 1;
		}else if(function == 1)
		{
			printf("输入设置读取时间间隔（0-255，单位10ms）：");
			scanf("%d",&output_interval);
			if(output_interval<0 || output_interval>255)
			{
				perror("输入错误，再见！");
				return 1;
			}
			memset(sbuf, 0, 8*sizeof(unsigned char));
			crc_ready[0] = (unsigned char)0x01;//设备地址
			crc_ready[1] = (unsigned char)0x06;//Modbus功能号6
			crc_ready[2] = (unsigned char)0x02;//寄存器地址：0x0207，主动读取时间间隔
			crc_ready[3] = (unsigned char)0x07;
			crc_ready[4] = (unsigned char)( (output_interval & 0xFF00) >> 8);
			crc_ready[5] = (unsigned char)( output_interval & 0xFF);
			crc_value = calc_crc16(crc_ready, 6);
			memcpy(sbuf, crc_ready, 6);
			sbuf[7] =  (unsigned char)( (crc_value & 0xFF00) >> 8);
			sbuf[6] =  (unsigned char)( crc_value & 0xFF);
			for(i=0; i< 8; i++)
				printf("%02x ",sbuf[i]);  
			putchar(10);
			retv=write(fd,sbuf,length); /*发送控制命令数据*/
				if(retv==-1)
					perror("write");
			return 0;
		}
		else{
			while(1)
			{

				/*构造发送数据：
				头部：1B,0x55
				类型+序列号：3B：2b：类型，22b：序列号
				数据：3B：12b：电压，12b：电流
				尾部：1B，0xAA
				*/

				rbuf=hd;

				sbuf[0] = (unsigned char)0x55;    //头部，固定
				sbuf[1] = (unsigned char)((0x40)|((index&0x3F0000)>>16));    //前两个bit为类型，此处以10B电压源数据为例，后6bit为index前6位
				sbuf[2] = (unsigned char)((index &0xFF00)>>8);    //去除头6bit后的一个字节
				sbuf[3] = (unsigned char)(index & 0xFF);    //取index最后一个字节

				srand((unsigned)time(NULL)*index);
				vol = (unsigned int)(rand()%30+1);    //0.0-3.0V的随机数,此处扩大10倍
				curr = (unsigned int)(rand()%50+1);  //0.00-0.50A的随机数，此处扩大100倍
				sbuf[4] = (unsigned char)( (vol &0xFF0)>>4);//电压数据前八bit放入第一个Byte
				sbuf[5] = (unsigned char)(((vol&0xF)<<4)|((curr &0xF00)>>8));//电压数据的后四位和电流数据的前4位
				sbuf[6] = (unsigned char)(curr & 0xFF);//电流数据的后8位
				sbuf[7] = (unsigned char)0xAA;        //尾部

				index ++;

				retv=write(fd,sbuf,length); /*接收数据*/
				if(retv==-1)
					perror("write");

				printf("Raw vol: %d, Curr: %d\n",vol,curr);
				printf("Sent data(Hex): %02x %02x %02x %02x     %02x %02x %02x %02x\n",sbuf[0],sbuf[1],sbuf[2],sbuf[3],sbuf[4],sbuf[5],sbuf[6],sbuf[7]);

			   /* sleep(1);

				printf("Ready for receiving data...\n");
				retv=read(fd,rbuf,2);
				if(retv==-1)
				{
						perror("read");
				}else{
						printf("The data received is:\n");
						printf("0x%x  ",hd[0]);printf("0x%x",hd[1]);
						printf("\n\n\n");
				}*/

				printf("\n\n\n");
				usleep(100000);

			}
		}
		flag_close =close(fd);
		if(flag_close == -1) /*判断是否成功关闭文件*/
			printf("Close the Device failur！\n");

		return 0;
}
