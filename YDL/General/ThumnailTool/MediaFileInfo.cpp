
#include "libavformat/avformat.h"
#include "libavcodec/avcodec.h"
#include "libswscale/swscale.h"
#include "libavutil/imgutils.h"
#include <fstream>
#include <iostream>
#include "stdint.h"
#include "ffbri.h"
#include "fcntl.h" 
#include "MediaFileInfo.h"

#include <sys/stat.h>
#include <assert.h>

#if defined(_WIN32)
#include <windows.h>
#include <io.h>



#define localtime(t) _localtime64(t)
#define stat _stati64
#define fstat(f,s) _fstati64((f), (s))
#define lseek(f,p,w) _lseeki64((f), (p), (w))

static inline int utf8towchar(const char *filename_utf8, wchar_t **filename_w)
{
	int num_chars;
	num_chars = MultiByteToWideChar(CP_UTF8, MB_ERR_INVALID_CHARS, filename_utf8, -1, NULL, 0);
	if (num_chars <= 0) {
		*filename_w = NULL;
		return 0;
	}
	*filename_w = (wchar_t *)malloc(num_chars * sizeof(wchar_t));
	if (!*filename_w) 
	{
		return -1;
	}
	MultiByteToWideChar(CP_UTF8, 0, filename_utf8, -1, *filename_w, num_chars);
	return 0;
}
#else
#include <unistd.h>
#endif

#include "bmp.h"


int SaveThumbnail(AVFrame* pFrame, MYThumbnailinfo* pInfo)
{
	AVPicture dstPic;
	dstPic.linesize[0] = LINESIZE(pInfo->width * 24);
	dstPic.data[0] = pInfo->buf;  
	//img_convert_ffbri(&dstPic, AV_PIX_FMT_RGB24, pInfo->width, pInfo->height, (AVPicture *)pFrame, pFrame->format, pFrame->width, pFrame->height);
	img_convert_ffbri(&dstPic, AV_PIX_FMT_BGR24, pInfo->width, pInfo->height, (AVPicture *)pFrame, pFrame->format, pFrame->width, pFrame->height);
	return 0;
}
/*
void fflog(void* ptr, int level, const char* fmt,va_list vl){  
	FILE *fp = fopen("d:\\ff_log.txt","a+");     
	if(fp)
	{     
		vfprintf(fp,fmt,vl);  
		fflush(fp);  
		fclose(fp);  
	}     
}  
*/
void GetFileInfo(const char* pFileName, MYMediaInfo* pMediaInfo)
{
	//get file info
	const char* p1 = strrchr(pFileName, '\\');
	const char* p2 = strrchr(pFileName, '/');
	const char* p = p1 < p2 ? p2 : p1;

	strcpy(pMediaInfo->file_path, pFileName);

	strcpy(pMediaInfo->file_title, p + 1);

	//strcpy(pMediaInfo->file_type, fmt_ctx->iformat->name);
	p = strrchr(pFileName, '.');
	strcpy(pMediaInfo->file_type, p + 1);

	//
	int fd;
	int access = O_RDONLY;

#ifdef O_BINARY
	access |= O_BINARY;
#endif

#if defined(_WIN32)
	wchar_t *filename_w;

	/* convert UTF-8 to wide chars */
	if (utf8towchar(pFileName, &filename_w))
	{

	}

	if (!filename_w)
	{

	}

	fd = _wsopen(filename_w, access, 0x40, 0666);
	free(filename_w);
#else
	fd = open(pFileName, access, 0666);
#endif

	if(fd > 0)
	{
		struct stat st;

		int64_t ret = fstat(fd, &st);
		pMediaInfo->file_size = st.st_size;

		struct tm* t = localtime(&st.st_mtime);
		//sprintf(pMediaInfo->file_date, "%04d/%02d/%02d %02d:%02d:%02d", t->tm_year + 1900, t->tm_mon + 1, t->tm_mday, t->tm_hour, t->tm_min, t->tm_sec);
		pMediaInfo->file_datetime.tm_hour =  t->tm_hour;
		pMediaInfo->file_datetime.tm_mday = t->tm_mday;
		pMediaInfo->file_datetime.tm_min = t->tm_min;
		pMediaInfo->file_datetime.tm_mon = t->tm_mon + 1;
		pMediaInfo->file_datetime.tm_sec = t->tm_sec;
		pMediaInfo->file_datetime.tm_year = t->tm_year + 1900;
		close(fd);
	}
};

void ExtractMetaInfo(AVDictionary *metadata,MYMediaInfo* pMediaInfo)
{
	AVDictionaryEntry *tag = NULL;
	char * pDect = NULL;
	if (!metadata || !pMediaInfo)
	{
		return ;
	}
	
	tag = av_dict_get_ffbri(metadata, "title", tag, 0);
	if (tag && tag->value)
	{
		strcpy(pMediaInfo->meta_title, tag->value);
	}
	tag = av_dict_get_ffbri(metadata, "artist", tag, 0);
	if (tag && tag->value)
	{
		strcpy(pMediaInfo->meta_artist, tag->value);
	}
	tag = av_dict_get_ffbri(metadata, "album", tag, 0);
	if (tag && tag->value)
	{
		strcpy(pMediaInfo->meta_album, tag->value);
	}
	tag = av_dict_get_ffbri(metadata, "genre", tag, 0);
	if (tag && tag->value)
	{
		strcpy(pMediaInfo->meta_genre, tag->value);
	}
		tag = av_dict_get_ffbri(metadata, "date", tag, 0);
	if (tag && tag->value)
	{
		strcpy(pMediaInfo->meta_date, tag->value);
	}

}
MYMediaInfo* AllocMediaInfo()
{
	MYMediaInfo* pHandle = new MYMediaInfo;
	pHandle->audioinfo.bitrate  =0;
	pHandle->audioinfo.channels = 0;
	pHandle->audioinfo.codename[0] = 0;
	pHandle->audioinfo.samplerate = 0;

	pHandle->duration = 0;

	pHandle->fHasAudio = 0;
	pHandle->fHasVideo = 0;

	pHandle->file_path[0] = 0;
	pHandle->file_size = 0;
	pHandle->file_title[0] = 0;
	pHandle->file_type[0] =0;
	pHandle->file_datetime.tm_sec = 0;
	pHandle->file_datetime.tm_year = 0;
	pHandle->file_datetime.tm_hour = 0;
	pHandle->file_datetime.tm_mday = 0;
	pHandle->file_datetime.tm_min = 0;
	pHandle->file_datetime.tm_mon = 0;

	pHandle->videoinfo.bitrate = 0;
	pHandle->videoinfo.codename[0] = 0;
	pHandle->videoinfo.height = 0;
	pHandle->videoinfo.width = 0;

	pHandle->videoinfo.fHasThumbnail = 0;

	pHandle->videoinfo.thumbnail.height = 96;
	pHandle->videoinfo.thumbnail.width = 128;
	int bytesize = LINESIZE(pHandle->videoinfo.thumbnail.width * 24) * pHandle->videoinfo.thumbnail.height;
	pHandle->videoinfo.thumbnail.buf = new unsigned char[bytesize];

	pHandle->meta_album[0] = 0;
	pHandle->meta_artist[0] = 0;
	pHandle->meta_genre[0] = 0;
	pHandle->meta_title[0] = 0;
	pHandle->meta_date[0] = 0;
	return pHandle;
}
void FreeMediaInfo(MYMediaInfo * pHandle)
{
	if (pHandle)
	{
		if (pHandle->videoinfo.thumbnail.buf)
		{
			delete []pHandle->videoinfo.thumbnail.buf;
		}
		delete pHandle;
	}

}

void SetThumbnailDimension(MYMediaInfo* pHandle,unsigned int width,unsigned int height)
{
	assert(pHandle);

	pHandle->videoinfo.thumbnail.height = height;
	pHandle->videoinfo.thumbnail.width = width;
	int bytesize = LINESIZE(pHandle->videoinfo.thumbnail.width * 24) * pHandle->videoinfo.thumbnail.height;
	if (pHandle->videoinfo.thumbnail.buf)
	{
		delete [](pHandle->videoinfo.thumbnail.buf);
	}
	pHandle->videoinfo.thumbnail.buf = new unsigned char[bytesize];
}


int GetMediaInfo(const char* pFileName, MYMediaInfo* pMediaInfo)
{
	assert(pFileName);
	assert(pMediaInfo);
	AVFormatContext *fmt_ctx = NULL;
	AVCodecContext *video_dec_ctx = NULL;
	AVCodecContext *audio_dec_ctx = NULL;
	AVStream *video_stream = NULL;
	AVStream *audio_stream = NULL;

	int video_stream_idx = -1;
	int audio_stream_idx = -1;
	AVFrame *video_frame = NULL;
	AVPacket pkt;
	int ret = MY_OK;
	int64_t nDuration = 0;
	bool bIsVedioStream = false;
	GetFileInfo(pFileName, pMediaInfo);

	av_register_all_ffbri();

	//av_log_set_callback_ffbri(fflog);

	pMediaInfo->fHasAudio = 0;
	pMediaInfo->fHasVideo = 0;

	/* open input file, and allocate format context */
	if (av_open_input_file_ffbri(&fmt_ctx, pFileName, NULL, 0, NULL) < 0) 
	{
		ret = MYERROR(MY_OPEN_FILE_FAIL);
		//goto End;
        avcodec_close_ffbri(video_dec_ctx);
        avcodec_close_ffbri(audio_dec_ctx);
        av_close_input_file_ffbri(fmt_ctx);
        
        avcodec_free_frame_ffbri(&video_frame);
        
        return ret;
    }

	if (av_find_stream_info_ffbri(fmt_ctx) < 0) 
	{
		ret = MYERROR(MY_NOT_FOUND_STREAM);
		//goto End;
        avcodec_close_ffbri(video_dec_ctx);
        avcodec_close_ffbri(audio_dec_ctx);
        av_close_input_file_ffbri(fmt_ctx);
        
        avcodec_free_frame_ffbri(&video_frame);
        
        return ret;
    }

	for(unsigned int i = 0; i < fmt_ctx->nb_streams; i++)
	{
		/*
		if (fmt_ctx->streams[i]->disposition & AV_DISPOSITION_ATTACHED_PIC)
		{
			printf("cover");
		}
		*/
		if(fmt_ctx->streams[i]->codec->codec_type == AVMEDIA_TYPE_VIDEO && video_stream_idx < 0)
		{
			AVDictionary *opts = NULL;
			video_stream = fmt_ctx->streams[i];
			video_dec_ctx = video_stream->codec;
			//add by jwg,20170427,ÐÞ¸Ä¿ÕÊÓÆµÁ÷bug
			if (video_dec_ctx->codec_id == AV_CODEC_ID_NONE)
			{
				video_stream = NULL;
				video_dec_ctx = NULL;
				continue;
			}
			AVCodec *dec = avcodec_find_decoder_ffbri(video_dec_ctx->codec_id);;
			av_dict_set_ffbri(&opts, "refcounted_frames", "1", 0);

			/*È¡Á÷Ê±¼ä*/
			/*
			nDuration = video_stream->duration;
			nDuration = nDuration* video_stream->time_base.num * 1000*1000 / video_stream->time_base.den; //×ªÊ±¼äµ¥Î» us
		
			if (!nDuration)
			{
				if (video_dec_ctx->bit_rate)
				{
					nDuration = pMediaInfo->file_size*8*1000*1000 /video_dec_ctx->bit_rate; //µ¥Î»us;
				}
			}
			*/
			 
			//int nRotateAngle = GetRotate(fmt_ctx->metadata);
			//int nResumeAngle = ScaleResumeNormalRotate(nRotateAngle);
			//char szBuffer[32] = {0};
			//sprintf(szBuffer,"%d",nResumeAngle);
			//SetRotate(video_stream,szBuffer);
			if (avcodec_open_ffbri(video_stream->codec, dec, &opts) < 0) 
			{
				ret = MYERROR(MY_OPEN_VIDEO_CODEC_FAIL);
				//goto End;
                avcodec_close_ffbri(video_dec_ctx);
                avcodec_close_ffbri(audio_dec_ctx);
                av_close_input_file_ffbri(fmt_ctx);
                
                avcodec_free_frame_ffbri(&video_frame);
                
                return ret;
            }
	
			video_stream_idx = i;
            
            int frameRate_num = video_dec_ctx->framerate.num;
            int frameRate_den = video_dec_ctx->framerate.den;
            int frameRate = frameRate_num/frameRate_den;
            pMediaInfo->videoinfo.frameRate =  frameRate;
        
			pMediaInfo->videoinfo.bitrate = video_dec_ctx->bit_rate;
			pMediaInfo->videoinfo.width = video_dec_ctx->width;
			pMediaInfo->videoinfo.height = video_dec_ctx->height;
			strcpy(pMediaInfo->videoinfo.codename,video_dec_ctx->codec->name);
            
            //宽高比Damon
            float width = pMediaInfo->videoinfo.width;
            float height = pMediaInfo->videoinfo.height;
            float aspectRadio_num = video_dec_ctx->sample_aspect_ratio.num;
            float aspectRadio_den = video_dec_ctx->sample_aspect_ratio.den;
            float scale = aspectRadio_num /aspectRadio_den;
            int scaleWith  = (scale == 0)?(width):(width*scale);
            int scaleHeigt = (scale == 0)?(height):(height*scale);
            
            int shuMax = 0;
            int flag=scaleWith<scaleHeigt?scaleWith:scaleHeigt;
            for(int i=flag;i>=0;i--)
            {
                if(scaleWith%i==0&&scaleHeigt%i==0)
                {
                    //获得最大公约数
                    shuMax = i;
                    pMediaInfo->videoinfo.aspectRadio_Width = scaleWith/shuMax;
                    pMediaInfo->videoinfo.aspectRadio_height = scaleHeigt/shuMax;
                    break;
                }
            }

			pMediaInfo->fHasVideo = 1;
			if (video_dec_ctx->bit_rate)
			{
				bIsVedioStream = true;
			}
		}
		else if(fmt_ctx->streams[i]->codec->codec_type == AVMEDIA_TYPE_AUDIO && audio_stream_idx < 0)
		{
			audio_stream = fmt_ctx->streams[i];
			audio_dec_ctx = audio_stream->codec;
			audio_stream_idx = i;
			pMediaInfo->audioinfo.bitrate = audio_dec_ctx->bit_rate;
			pMediaInfo->audioinfo.channels = audio_dec_ctx->channels;
			pMediaInfo->audioinfo.samplerate = audio_dec_ctx->sample_rate;
			AVCodec *dec = avcodec_find_decoder_ffbri(audio_dec_ctx->codec_id);
			strcpy(pMediaInfo->audioinfo.codename, dec->name);

			pMediaInfo->fHasAudio = 1;
		}
	}

	/* dump input information to stderr */
	av_dump_format_ffbri(fmt_ctx, 0, pFileName, 0);



	if (fmt_ctx->duration > 0)
	{
		pMediaInfo->duration = fmt_ctx->duration;
	}
	else
	{
		pMediaInfo->duration = 0;
	}
	ExtractMetaInfo(fmt_ctx->metadata,pMediaInfo);
	
	if (!video_stream) 
	{
		ret = MY_OK;
		//goto  End;
        avcodec_close_ffbri(video_dec_ctx);
        avcodec_close_ffbri(audio_dec_ctx);
        av_close_input_file_ffbri(fmt_ctx);
        
        avcodec_free_frame_ffbri(&video_frame);
        
        return ret;
    }

	video_frame = avcodec_alloc_frame_ffbri();
	if (!video_frame) 
	{
		ret = MYERROR(MY_ALLOC_FRAME_FAIL);
		//goto End;
        avcodec_close_ffbri(video_dec_ctx);
        avcodec_close_ffbri(audio_dec_ctx);
        av_close_input_file_ffbri(fmt_ctx);
        
        avcodec_free_frame_ffbri(&video_frame);
        
        return ret;
    }

	av_init_packet_ffbri(&pkt);
	pkt.data = NULL;
	pkt.size = 0;

	int64_t seekpos = 0;
	//if(pMediaInfo->duration > 10000000)
	if(pMediaInfo->duration > 10000000 && bIsVedioStream) // > 10s ÒÆµ½ÊÓÆµÖÐ¼äÎ»ÖÃ
	{
		static const AVRational q = {1, AV_TIME_BASE };  //us µ¥Î» 
		seekpos = pMediaInfo->duration / 2; 
		seekpos = av_rescale_q_ffbri ( seekpos, q, fmt_ctx->streams[video_stream_idx]->time_base );
		av_seek_frame_ffbri(fmt_ctx, video_stream_idx, seekpos, AVSEEK_FLAG_BACKWARD);
	}

	int got_frame;

	int got_thumbnail = 0;

	/* read frames from the file */
	int decret = 0;
	while (av_read_frame_ffbri(fmt_ctx, &pkt) >= 0) 
	{
		AVPacket orig_pkt = pkt;
		if(pkt.stream_index == video_stream_idx)
		{
			do 
			{
				decret = avcodec_decode_video2_ffbri(video_dec_ctx, video_frame, &got_frame, &pkt);
				if (avcodec_decode_video2_ffbri(video_dec_ctx, video_frame, &got_frame, &pkt) <= 0) 
				{
					break;
				}

				//png format
				if(!got_frame && 
					(video_dec_ctx->codec_id == AV_CODEC_ID_PNG || 
					video_dec_ctx->codec_id == AV_CODEC_ID_TIFF))
				{
					pkt.data = NULL;
					pkt.size = 0;
					avcodec_decode_video2_ffbri(video_dec_ctx, video_frame, &got_frame, &pkt);
				}

				if(got_frame && video_frame->key_frame)
				{
#if 0
					FILE* yuvfile = fopen("frame.yuv", "wb");
					unsigned char* ydata = video_frame->data[0];
					for(int i = 0; i < srcheight; i++)
					{
						fwrite(ydata, 1, srcwidth, yuvfile);
						ydata += video_frame->linesize[0];
					}

					unsigned char* udata = video_frame->data[1];
					for(int i = 0; i < srcheight / 2; i++)
					{
						fwrite(udata, 1, srcwidth / 2, yuvfile);
						udata += video_frame->linesize[1];
					}

					unsigned char* vdata = video_frame->data[2];
					for(int i = 0; i < srcheight / 2; i++)
					{
						fwrite(vdata, 1, srcwidth / 2, yuvfile);
						vdata += video_frame->linesize[2];
					}
					fclose(yuvfile);
#endif
				
					SaveThumbnail(video_frame, &pMediaInfo->videoinfo.thumbnail);
					/*add by jwg,20170421,Ö¸Ê¾thumbnail  if exist*/
					pMediaInfo->videoinfo.fHasThumbnail = 1;
					got_thumbnail = 1;
					break;
				}
				pkt.data += decret;
				pkt.size -= decret;
			} while (pkt.size > 0);
		}

		av_free_packet_ffbri(&orig_pkt);

		if(got_thumbnail)
		{
			break;
		}
	}

End:
	avcodec_close_ffbri(video_dec_ctx);
	avcodec_close_ffbri(audio_dec_ctx);
	av_close_input_file_ffbri(fmt_ctx);

	avcodec_free_frame_ffbri(&video_frame);

	return ret;
}

 void InitMyMediaInfo(MYMediaInfo* pHandle)
 {
		assert(pHandle);
		pHandle->audioinfo.bitrate  =0;
		pHandle->audioinfo.channels = 0;
		pHandle->audioinfo.codename[0] = 0;
		pHandle->audioinfo.samplerate = 0;

		pHandle->duration = 0;

		pHandle->fHasAudio = 0;
		pHandle->fHasVideo = 0;

		pHandle->file_path[0] = 0;
		pHandle->file_size = 0;
		pHandle->file_title[0] = 0;
		pHandle->file_type[0] =0;
		pHandle->file_datetime.tm_sec = 0;
		pHandle->file_datetime.tm_year = 0;
		pHandle->file_datetime.tm_hour = 0;
		pHandle->file_datetime.tm_mday = 0;
		pHandle->file_datetime.tm_min = 0;
		pHandle->file_datetime.tm_mon = 0;

		pHandle->videoinfo.bitrate = 0;
		pHandle->videoinfo.codename[0] = 0;
		pHandle->videoinfo.height = 0;
		pHandle->videoinfo.width = 0;
	    pHandle->videoinfo.fHasThumbnail = 0;
		//pHandle->videoinfo.thumbnail.buf = NULL;
		//pHandle->videoinfo.thumbnail.height = 0;
		//pHandle->videoinfo.thumbnail.width = 0;
		//int bytesize = LINESIZE(pHandle->videoinfo.thumbnail.width * 24) * pHandle->videoinfo.thumbnail.height;
		//if (pHandle->videoinfo.thumbnail.buf)
		//{
		//	delete [](pHandle->videoinfo.thumbnail.buf);
		//}
		//pHandle->videoinfo.thumbnail.buf = new unsigned char[bytesize];

		pHandle->meta_album[0] = 0;
		pHandle->meta_artist[0] = 0;
		pHandle->meta_genre[0] = 0;
		pHandle->meta_title[0] = 0;
		pHandle->meta_date[0] = 0;
 }


 
 unsigned char*  GenerateBmp(MYMediaInfo * pHandle,unsigned long* pSize)
{
	CBmp bmp;
	
	if (!pHandle || !pSize)
	{
		return NULL;
	}
	if (!pHandle->fHasVideo || !pHandle->videoinfo.fHasThumbnail)
	{
		return NULL;
	}
	int bytesize = LINESIZE(pHandle->videoinfo.thumbnail.width * 24) * pHandle->videoinfo.thumbnail.height;
	int linesize = LINESIZE(pHandle->videoinfo.thumbnail.width * 24);
	
	/*Ç°ºó½»»»Êý¾Ý*/			
	unsigned char* pLineByte = new unsigned char[linesize];
	unsigned char* bufheader = pHandle->videoinfo.thumbnail.buf;
	unsigned char* buftail = bufheader + ( pHandle->videoinfo.thumbnail.height - 1) * linesize;
	for(int i = 0; i < pHandle->videoinfo.thumbnail.height / 2; i++)
	{
		memcpy(pLineByte, bufheader, linesize);
		memcpy(bufheader, buftail, linesize);
		memcpy(buftail, pLineByte, linesize);
		bufheader += linesize;
		buftail -= linesize;
	}
	delete [] pLineByte;
						
	unsigned long nImagesize = 0;
	bmp.Data(pHandle->videoinfo.thumbnail.buf,bytesize,
						pHandle->videoinfo.thumbnail.width,pHandle->videoinfo.thumbnail.height);

	unsigned char* pImage = NULL;
	nImagesize = bmp.ImageSize();
		
	if (nImagesize)
	{
		pImage = new unsigned char[nImagesize];
		nImagesize = bmp.Save(pImage,nImagesize);
		if (!nImagesize)
		{
			delete []pImage;
			pImage = NULL;
		}
		*pSize = nImagesize; 
	}
	return pImage;
}

void FreeBmp(unsigned char*  pBmp)
{
	if (pBmp)
	{
		delete []pBmp;
	}
}
// Verify that the heif file is encoded with HEVC.
static struct SwsContext* swsContext;
using namespace std;

void decodeHEIF(uint8_t *memoryBuffer,uint64_t memoryBufferSize,RGBData *rgb){
   
    av_register_all_ffbri();
    avcodec_register_all_ffbri();
    // Get HEVC decoder configuration
    AVCodec *codec = avcodec_find_decoder_ffbri(AV_CODEC_ID_HEVC);
    AVCodecContext *c = avcodec_alloc_context_ffbri(codec);
    
    AVFrame* frame = avcodec_alloc_frame_ffbri();
    AVPacket* packet = avcodec_alloc_Packet_ffbri();
    
    packet->size = static_cast<int>(memoryBufferSize);
    packet->data = ((uint8_t*)(&memoryBuffer[0]));
    auto* errorDescription = new char[256];
    
    
    // handle error!
    int sent = avcodec_send_packet_ffbri(c, packet);
    if (sent < 0)
    {
//        av_strerror(sent, errorDescription, 256);
//        cerr << "Error sending packet to HEVC decoder: " << errorDescription << endl;
//        throw sent;
        return;
    }
    int success = avcodec_receive_frame_ffbri(c, frame);
    if (success != 0)
    {
//        av_strerror(success, errorDescription, 256);
//        cerr << "Error decoding frame: " << errorDescription << endl;
//        throw success;
         return;
    }
    delete[] errorDescription;
    size_t bufferSize = static_cast<size_t>(av_image_get_buffer_size_ffbri(
                                                                     AV_PIX_FMT_RGB24, frame->width, frame->height, 1));

    rgb->data = (uint8_t *) malloc(bufferSize);
    rgb->size = bufferSize;
    rgb->width = frame->width;
    rgb->height = frame->height;
    

    // Convert colorspace of decoded frame load into buffer
    // copyFrameInto(frame, rgb->data, rgb->size);
    AVFrame* imgFrame = avcodec_alloc_frame_ffbri();
    auto tempBuffer = (uint8_t*) av_malloc_ffbri(rgb->size);
    struct SwsContext *sws_ctx = sws_getCachedContext_ffbri(
                                                      swsContext,
                                                      rgb->width, rgb->height, AV_PIX_FMT_YUV420P,
                                                      rgb->width, rgb->height, AV_PIX_FMT_RGB24,
                                                      0, nullptr, nullptr, nullptr);
    
    av_image_fill_arrays_ffbri(imgFrame->data, imgFrame->linesize,
                         tempBuffer, AV_PIX_FMT_RGB24, rgb->width, rgb->height, 1);
    auto* const* frameDataPtr = (uint8_t const* const*)frame->data;
    
    // Convert YUV to RGB
    sws_scale_ffbri(sws_ctx, frameDataPtr, frame->linesize, 0,
              rgb->height, imgFrame->data, imgFrame->linesize);
    
    // Move RGB data in pixel order into memory
    auto dataPtr = static_cast<const uint8_t* const*>(imgFrame->data);
    auto size = static_cast<int>(rgb->size);
    av_image_copy_to_buffer_ffbri(rgb->data, size, dataPtr,
                                      imgFrame->linesize, AV_PIX_FMT_RGB24,  rgb->width, rgb->height, 1);
    
    av_free_ffbri(imgFrame);
    av_free_ffbri(tempBuffer);
    avcodec_close_ffbri(c);
    av_free_ffbri(c);
    av_free_ffbri(frame);

}
