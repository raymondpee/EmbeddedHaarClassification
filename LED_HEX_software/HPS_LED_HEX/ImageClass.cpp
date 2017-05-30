#include "ImageClass.hpp"
#include <opencv.hpp>

using namespace cv;


void ImageClass::ImageClass(string name)
{
	ReadImage(name);
}

void ImageClass::ImageClass(int width, int height)
{
	m_width = width;
	m_height = height;
	m_data = new unsigned char[width*height];
}

void ImageClass::ReadImage(string name)
{
	Mat Image = imread(name,0);
	m_width = Image.cols;
	m_height = Image.rows;
	
	unsigned char* imgData = m_Image.data;
	int size = m_width*m_height;
	if(m_data == NULL)
	{
		m_data = new unsigned char[size];
	}
	unsigned char* localdata = m_data;
	unsigned char* localimgData = imgData;
	
	for(int index = 0; index<size; index++)
	{
		*localdata++ = *localimgData++; 
	}
}

void WriteImage(string name)
{
	Mat matdst(m_height, m_width, CV_8U,m_data);
	imwrite(name,matdst);
}