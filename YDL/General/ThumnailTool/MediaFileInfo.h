#ifndef MediaFileInfo_h__
#define MediaFileInfo_h__

#define MYERROR(e) (-(e)) 

#define LINESIZE(bits) ((unsigned int)(((bits)+31) & (~31)) / 8)

enum tagMYMediaInfoErrorCode 
{
	MY_OK = 0,
	MY_OPEN_FILE_FAIL,
	MY_NOT_FOUND_STREAM,
	MY_OPEN_VIDEO_CODEC_FAIL,
	MY_NO_VIDEO_STREAM,
	MY_ALLOC_FRAME_FAIL,
	MY_DECODE_ERROR,
};

typedef struct tagMYThumbnailinfo
{
	int width;
	int height;
	unsigned char* buf;
}MYThumbnailinfo;

typedef	struct tagMYVideoInfo
{
	int width;
	int height;
	char codename[16];
	int bitrate;
	/*add by jwg,20170421*/
	int fHasThumbnail;
	MYThumbnailinfo thumbnail;
    int frameRate;
    int aspectRadio_Width;
    int aspectRadio_height;
}MYVideoInfo;

typedef	struct tagMYAudioInfo
{
	int samplerate;
	int channels;
	char codename[16];
	int bitrate;
}MYAudioInfo;

typedef struct tagMYDateTime
{
	int tm_sec;     
	int tm_min;     
	int tm_hour;    
	int tm_mday;    
	int tm_mon;     
	int tm_year;   
}MYDateTime;

typedef struct tagMYMediaInfo
{
	long long duration; //ms
	char file_title[300];
	char file_path[4096];
	char file_type[32];
	long long  file_size;
	MYDateTime  file_datetime;
	int fHasVideo;
	MYVideoInfo videoinfo;
	int fHasAudio;
	MYAudioInfo audioinfo;
	char meta_title[300];
	char meta_album[64];
	char meta_artist[64];
	char meta_date[24];
	char meta_genre[32];

}MYMediaInfo;

typedef struct tagRGBData
{
    uint8_t * data;
    unsigned long size;
    int width;
    int height;
}RGBData;

#ifdef __cplusplus 
extern "C" 
{
#endif
/*������*/
MYMediaInfo* AllocMediaInfo();
/*�ͷž��*/
void FreeMediaInfo(MYMediaInfo * pHandle);


/*��ʼ��ý����Ϣ*/
void InitMyMediaInfo(MYMediaInfo* pHandle);
void SetThumbnailDimension(MYMediaInfo* pHandle,unsigned int width,unsigned int height);
/*��ȡý����Ϣ*/
int GetMediaInfo(const char* pFileName, MYMediaInfo* pMediaInfo);

/*
brief ��ȡbmp����ͼ
param pHandle ý����Ϣ���
param nImagesize ���ڱ���ͼ���ֽڴ�С
return ����ͼƬ�򷵻�һ��ͼƬָ�룬û�з���NULL
*/
unsigned char*  GenerateBmp(MYMediaInfo * pHandle,unsigned long* pSize);
/*�ͷ�GenerateBmp����bmp image ͼ��ָ�� */
void FreeBmp(unsigned char* );

void decodeHEIF(uint8_t *memoryBuffer,uint64_t memoryBufferSize,RGBData *rgbData);

#ifdef __cplusplus 
}
#endif

#endif // MediaFileInfo_h__
