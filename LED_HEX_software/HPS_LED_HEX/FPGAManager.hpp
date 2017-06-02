#ifndef FPGA_MANAGER_HPP
#define FPGA_MANAGER_HPP

#include "hwlib.h"
#include "socal/socal.h"
#include "socal/hps.h"
#include "socal/alt_gpio.h"
#include "hps_0.h"
#include "ResultData.hpp"
#include "FPGA_CONST.H"

#define HW_REGS_BASE ( ALT_STM_OFST )
#define HW_REGS_SPAN ( 0x04000000 )
#define HW_REGS_MASK ( HW_REGS_SPAN - 1 )

class FPGAManager
{
	private:
		volatile unsigned long *m_h2p_lw_hex_addr;
		int m_fd;
	
	private:
		void WriteToFPGA(unsigned long value){m_h2p_lw_hex_addr = value;}
		void WaitFPGA(int nanosecond);
		unsigned long ReadFromFPGA(){return *m_h2p_lw_hex_addr;}
		bool GetIsFPGAIdle(){return ReadFromFPGA() == FPGA_IDLE;}
		bool GetIsFPGAReadyRecievePixel(){return ReadFromFPGA() == FPGA_START_RECIEVE_PIXEL;}
		bool GetIsFPGAStopRecievePixel(){return ReadFromFPGA() == FPGA_STOP_RECIEVE_PIXEL;}
		bool GetIsFPGAStartSendResult(){return ReadFromFPGA() == FPGA_START_SEND_RESULT;}
		bool GetIsFPGAFinishSendAllResult(){return ReadFromFPGA() == FPGA_FINISH_RESULT;}
	public:
		FPGAManager();
	
	public:
		void StartFPGASystem();
		void WritePixelToFPGA(int pixel);
		vector<ResultData> ReadResultsFromFPGA();
	
	public:
		int ConnectBridge();
		int DisconnectBridge();
		unsigned long * GetFPGABridgeMemory(){return m_h2p_lw_hex_addr;}
};

#endif