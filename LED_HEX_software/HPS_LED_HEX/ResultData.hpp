#ifndef RESULT_DATA_HPP
#define RESULT_DATA_HPP

class ResultData
{
	private:
		int m_X;
		int m_Y;
		int m_scale;
		
	public: 
		ResultData(){}
		ResultData(int x, int y, int scale)
		{
			SetX(x);
			SetY(y);
			SetScale(scale);
		}
		
	public:
		int GetX(){return m_X;}
		int GetY(){return m_Y;}
		
		void SetX(int value){m_X = value;}
		void SetY(int value){m_Y = value;}
		void SetScale(int value){m_scale = value;}
};


#endif