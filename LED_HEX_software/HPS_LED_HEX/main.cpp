#include <iostream>
#include <string>
#include "FPGAManager.hpp"
#include "ImageClass.hpp"
#include "ResultData.hpp"
#include <vector>


#define DEBUG_MODE 0
using namespace std;


int main(int argc, char* argv[])
{
	string imgFileName = (string)argv[1];
	
	ImageClass imgSrc(imgFileName);
	ImageClass imgDst(imgFileName);
	unsigned char* srcData = imgSrc.GetData();
	int width = imgSrc.GetWidth();
	int height = imgSrc.GetHeight();
	int size = width*height;
	
	FPGAManager fpgaManager;
	fpgaManager.ConnectBridge();
	fpgaManager.ResetFPGASystem();
	
	// Send pixel to FPGA
	for(int index = 0; index<size; index++)
	{
		int pixel = *srcData++;
		fpgaManager.WritePixelToFPGA(pixel);
	}
	
	//Get Result from FPGA
	vector<ResultData> results = fpgaManager.ReadResultsFromFPGA();
	fpgaManager.DisconnectBridge();
}
