#ifndef IMAGE_CLASS_HPP
#define IMAGE_CLASS_HPP

#include <iostream>
#include <string>

using namespace std;

class ImageClass
{
	private:
		unsigned char* m_data;
		int m_width;
		int m_height;
		
	public:
		ImageClass()
		{
			m_data = NULL;
			m_width = 0;
			m_height = 0;
		}
		ImageClass(int width, int height);
		ImageClass(string name);
		
	public:
		unsigned char* GetData(){return m_data;}
		int GetWidth(){return m_width;}
		int GetHeight(){return m_height;}
		void ReadImage(string name);
};

#endif