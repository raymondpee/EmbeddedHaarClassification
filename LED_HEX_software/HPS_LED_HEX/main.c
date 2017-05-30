#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <time.h>
#include <sys/mman.h>

#include <stdbool.h>

void led_blink(void)
{
	int i=0;
	alt_write_word(h2p_lw_hex_addr, 30 ); 
	printf("%d",*h2p_lw_hex_addr);
}

int main(int argc, char **argv)
{
	void *virtual_base;
	int fd;
	// map the address space for the LED registers into user space so we can interact with them.
	// we'll actually map in the entire CSR span of the HPS since we want to access various registers within that span
	if( ( fd = open( "/dev/mem", ( O_RDWR | O_SYNC ) ) ) == -1 ) {
		printf( "ERROR: could not open \"/dev/mem\"...\n" );
		return( 1 );
	}
	virtual_base = mmap( NULL, HW_REGS_SPAN, ( PROT_READ | PROT_WRITE ), MAP_SHARED, fd, HW_REGS_BASE );	
	if( virtual_base == MAP_FAILED ) {
		printf( "ERROR: mmap() failed...\n" );
		close( fd );
		return(1);
	}
	h2p_lw_hex_addr=virtual_base + ( ( unsigned long  )( ALT_LWFPGASLVS_OFST + SEG7_IF_BASE ) & ( unsigned long)( HW_REGS_MASK ) );
	led_blink();	
	
	if( munmap( virtual_base, HW_REGS_SPAN ) != 0 ) {
		printf( "ERROR: munmap() failed...\n" );
		close( fd );
		return( 1 );
	}
	close( fd );
	return 0;
}