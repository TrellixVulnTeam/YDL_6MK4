#ifndef BMP_H
#define BMP_H


class CBmp
{
public:

typedef unsigned int       DWORD;
typedef unsigned short      WORD;
typedef int LONG;
typedef  unsigned char BYTE;

#pragma pack(push,2)
struct BmpFileHeader{
	WORD    bfType;
	DWORD   bfSize;
	WORD    bfReserved1;
	WORD    bfReserved2;
	DWORD   bfOffBits;
};
#pragma pack(pop)
 struct BmpInfoHeader{
   DWORD      biSize;
   LONG       biWidth;
   LONG       biHeight;
   WORD       biPlanes;
   WORD       biBitCount;
   DWORD      biCompression;
   DWORD      biSizeImage;
   LONG       biXPelsPerMeter;
   LONG       biYPelsPerMeter;
   DWORD      biClrUsed;
   DWORD      biClrImportant;
 };

struct BmpColorPalette{
  BYTE    rgbBlue; 
  BYTE    rgbGreen; 
  BYTE    rgbRed; 
  BYTE    rgbReserved; 
} ;
public:
	CBmp();
	~CBmp();
void Load(const char* file);
void Save(const char* file);
unsigned long Save(unsigned char* buffer,unsigned long size);
unsigned char* Data();
//unsigned char* Data(unsigned char* pDataBuffer,unsigned long nDataSize);
unsigned char* Data(unsigned char* pDataBuffer,unsigned long nDataSize,long nWidth,long nHeight);
unsigned long DataSize();
unsigned long ImageSize();
BmpInfoHeader m_infoHeader;
BmpFileHeader m_fileHeader;
protected:
unsigned char* m_pDataBuffer;
unsigned long m_nDataSize;
};

#endif //BMP_H
