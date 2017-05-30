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
		int STATE_RESET;
		int STATE_SEND_PIXEL_START;
		int STATE_SEND_PIXEL_END;
		int STATE_RECIEVE_RESULT_START;
		int STATE_RECIEVE_RESULT_END;
		int STATE_END;
	
	private:
		volatile unsigned long *m_h2p_lw_hex_addr;
		int m_fd;
	
	private:
		void WriteToFPGA(unsigned long value){m_h2p_lw_hex_addr = value;}
		unsigned long ReadFromFPGA(){return *m_h2p_lw_hex_addr;}
		bool GetIsStateReset(){return ReadFromFPGA() == STATE_RESET;}
		bool GetIsStateStartSendPixel(){return ReadFromFPGA() == STATE_SEND_PIXEL_START;}
		bool GetIsStateFinishSendPixel(){return ReadFromFPGA() == STATE_SEND_PIXEL_END;}
		bool GetIsStateRecieveResult(){return ReadFromFPGA() == STATE_RECIEVE_RESULT;}
		
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