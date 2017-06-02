#include "FPGAManager.hpp"
#include <time.h>

FPGAManager::FPGAManager()
{
	*m_h2p_lw_hex_addr = NULL;
	m_fd = 0;
}

void FPGAManager::WaitFPGA(int nanosecond)
{
	struct timespec req, rem;
	req.tv_sec = 0;                         /* Must be Non-Negative */
    req.tv_nsec = nanosecond;    /* Must be in range of 0 to 999999999 */
	nanosleep(&req , &rem);
}

int FPGAManager::ConnectBridge()
{
	// map the address space for the LED registers into user space so we can interact with them.
	// we'll actually map in the entire CSR span of the HPS since we want to access various registers within that span
	if( ( m_fd = open( "/dev/mem", ( O_RDWR | O_SYNC ) ) ) == -1 ) 
	{
		printf( "ERROR: could not open \"/dev/mem\"...\n" );
		return -1;
	}
	
	void * virtual_base = mmap( NULL, HW_REGS_SPAN, ( PROT_READ | PROT_WRITE ), MAP_SHARED, fd, HW_REGS_BASE );	
	if( virtual_base == MAP_FAILED ) {
		printf( "ERROR: mmap() failed...\n" );
		close( fd );
		return -1;
	}
	
	m_h2p_lw_hex_addr=virtual_base + ( ( unsigned long  )( ALT_LWFPGASLVS_OFST + SEG7_IF_BASE ) & ( unsigned long)( HW_REGS_MASK ) );
	ResetFPGASystem();
	return 0;
}

void FPGAManager::ResetFPGASystem()
{
	WriteToFPGA(FPGA_RESET);
}


vector<ResultData> ReadResultsFromFPGA()
{
	int delay_nanosecond = 2;
	vector<ResultData>results;
	do
	{		
		WriteToFPGA(LINUX_START_RECIEVE_RESULT);
		WaitFPGA(delay_nanosecond);
		int x = ReadFromFPGA();
		WriteToFPGA(LINUX_START_RECIEVE_RESULT);
		WaitFPGA(delay_nanosecond);
		int y = ReadFromFPGA();
		WriteToFPGA(LINUX_START_RECIEVE_RESULT);
		WaitFPGA(delay_nanosecond);
		int scale = ReadFromFPGA();
		WriteToFPGA(LINUX_STOP_RECIEVE_RESULT);
		WaitFPGA(delay_nanosecond);
		ResultData result(x,y,scale);
		results.push_back(result);
	}
	while(GetIsFPGAFinishSendAllResult());
	return results;
}


void FPGAManager::WritePixelToFPGA(int pixel)
{
	int delay_nanosecond = 2;
	while(!GetIsFPGAReadyRecievePixel()){WaitFPGA(delay_nanosecond);}
	WriteToFPGA(LINUX_START_SEND_PIXEL);
	WaitFPGA(delay_nanosecond);
	WriteToFPGA(pixel);
	WaitFPGA(delay_nanosecond);
	WriteToFPGA(LINUX_END_SEND_PIXEL);
	WaitFPGA(delay_nanosecond);
}


int FPGAManager::DisconnectBridge()
{
	if( munmap( virtual_base, HW_REGS_SPAN ) != 0 ) 
	{
		printf( "ERROR: munmap() failed...\n" );
		close( m_fd );
		return( 1 );
	}
	close( fd );
	return 0;
}
