#include "Bmp.h"
#include <assert.h>
#import "string.h"

CBmp::CBmp()
{
	m_pDataBuffer = NULL;
	m_nDataSize = 0;
	m_fileHeader.bfType = 0x4d42;
	m_fileHeader.bfOffBits = sizeof(CBmp::BmpFileHeader) + sizeof(CBmp::BmpInfoHeader);
	m_fileHeader.bfSize = m_fileHeader.bfOffBits + m_nDataSize;
	m_fileHeader.bfReserved1 = 0;
	m_fileHeader.bfReserved2 = 0;
	
	m_infoHeader.biBitCount = 24;
	m_infoHeader.biClrImportant = 0;
	m_infoHeader.biClrUsed = 0;
	m_infoHeader.biHeight = 0;
	m_infoHeader.biWidth = 0;
	m_infoHeader.biPlanes = 1;
	m_infoHeader.biCompression = 0;
	m_infoHeader.biSize = sizeof(BmpInfoHeader);
	m_infoHeader.biSizeImage = m_nDataSize;
	m_infoHeader.biXPelsPerMeter = 0;
	m_infoHeader.biYPelsPerMeter = 0;
}

CBmp::~CBmp()
{
	if (m_pDataBuffer)
	{
		delete []m_pDataBuffer;
	}
}
void CBmp::Load(const char* file)
{
 assert(0);
}
void CBmp::Save(const char* file)
{
	assert(0);
}
unsigned long CBmp::Save(unsigned char* buffer,unsigned long size)
{
	if (!buffer || size == 0)
	{
		return 0;
	}
	unsigned long nPos =0;
	unsigned long image_size = sizeof(BmpFileHeader)+ sizeof(BmpInfoHeader) + m_nDataSize;
	if (image_size > size)
	{
		return 0;
	}
	if (m_pDataBuffer && m_nDataSize)
	{
		memcpy(buffer,&m_fileHeader,sizeof(BmpFileHeader));
		nPos  = sizeof(BmpFileHeader);
		memcpy(buffer + nPos,&m_infoHeader,sizeof(BmpInfoHeader));
		nPos += sizeof(BmpInfoHeader);
		memcpy(buffer + nPos,m_pDataBuffer,m_nDataSize);
	}
	return image_size;
}
unsigned char* CBmp::Data()
{
	return m_pDataBuffer;
}
/*
unsigned char* CBmp::Data(unsigned char* pDataBuffer,unsigned long nDataSize)
{
	if (m_pDataBuffer)
	{
		delete []m_pDataBuffer;
		m_nDataSize = 0;
		m_pDataBuffer = NULL;
	}
	if (pDataBuffer  && nDataSize > 0)
	{
		m_nDataSize = nDataSize;
		m_pDataBuffer = new char[m_nDataSize]
		memcpy(m_pDataBuffer,pDataBuffer,m_nDataSize);
	}
	m_fileHeader.bfSize = bfh.bfOffBits + m_nDataSize;
	m_infoHeader.biSizeImage = m_nDataSize;
	return m_pDataBuffer
}
*/
unsigned char* CBmp::Data(unsigned char* pDataBuffer,unsigned long nDataSize,long nWidth,long nHeight)
{
	if (m_pDataBuffer)
	{
		delete []m_pDataBuffer;
		m_nDataSize = 0;
		m_pDataBuffer = NULL;
	}
	if (pDataBuffer  && nDataSize > 0)
	{
		m_nDataSize = nDataSize;
		m_pDataBuffer = new unsigned char[m_nDataSize];
		memcpy(m_pDataBuffer,pDataBuffer,m_nDataSize);
	}
	m_fileHeader.bfSize = m_fileHeader.bfOffBits + m_nDataSize;
	m_infoHeader.biSizeImage = m_nDataSize;
	m_infoHeader.biHeight = nHeight;
	m_infoHeader.biWidth = nWidth;
	return m_pDataBuffer;
}

unsigned long CBmp::DataSize()
{
	return m_nDataSize;
}
unsigned long CBmp::ImageSize()
{
	unsigned long image_size = 0;
	if (m_nDataSize)
	{
		image_size = sizeof(BmpFileHeader)+ sizeof(BmpInfoHeader) + m_nDataSize;
	}
	return image_size;
}
