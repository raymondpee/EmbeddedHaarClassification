#include "FPGAManager.hpp"

FPGAManager::FPGAManager()
{
	STATE_RESET = 900;
	STATE_SEND_PIXEL_START = 901;
	STATE_SEND_PIXEL_END = 902;
	STATE_RECIEVE_RESULT_START = 903;
	STATE_RECIEVE_RESULT_END = 904;
	STATE_END = 905;
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
	WriteToFPGA(STATE_RESET);
}


vector<ResultData> ReadResultsFromFPGA()
{
	vector<ResultData>results;
	do
	{		
		const int DONE = 1;
		int x = ReadFromFPGA();
		WriteToFPGA(DONE);
		int y = ReadFromFPGA();
		WriteToFPGA(DONE);
		int scale = ReadFromFPGA();
		WriteToFPGA(DONE);
		ResultData result(x,y,scale);
		results.push_back(result);
	}
	while(GetIsStateRecieveResult());
	return results;
}


void FPGAManager::WritePixelToFPGA(int pixel)
{
	WriteToFPGA(STATE_SEND_PIXEL_START);
	WriteToFPGA(pixel);
	WriteToFPGA(STATE_SEND_PIXEL_END);
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
