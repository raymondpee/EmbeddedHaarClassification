#ifndef FPGA_MANAGER_HPP
#define FPGA_MANAGER_HPP

#include "hwlib.h"
#include "socal/socal.h"
#include "socal/hps.h"
#include "socal/alt_gpio.h"
#include "hps_0.h"
#include "ResultData.hpp"

#define HW_REGS_BASE ( ALT_STM_OFST )
#define HW_REGS_SPAN ( 0x04000000 )
#define HW_REGS_MASK ( HW_REGS_SPAN - 1 )

class FPGAManager
{
	private:
		int LINUX_CALL_FPGA_RESET;
		int LINUX_START_SEND_PIXEL;
		int LINUX_END_SEND_PIXEL;
		
		int FPGA_READY_RECIEVE_PIXEL;
		int FPGA_END_RECIEVE_PIXEL;
		
		int STATE_RECIEVE_RESULT_START;
		int STATE_RECIEVE_RESULT_END;
		int STATE_END;
	
	private:
		volatile unsigned long *m_h2p_lw_hex_addr;
		int m_fd;
	
	private:
		void WriteToFPGA(unsigned long value){m_h2p_lw_hex_addr = value;}
		void WaitFPGA(int nanosecond);
		unsigned long ReadFromFPGA(){return *m_h2p_lw_hex_addr;}
		bool GetIsStateReset(){return ReadFromFPGA() == FPGA_RESET;}
		bool GetIsStateStartSendPixel(){return ReadFromFPGA() == LINUX_START_SEND_PIXEL;}
		bool GetIsStateFinishSendPixel(){return ReadFromFPGA() == LINUX_END_SEND_PIXEL;}
		bool GetIsStateStartRecieveResult(){return ReadFromFPGA() == STATE_RECIEVE_RESULT_START;}
		
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