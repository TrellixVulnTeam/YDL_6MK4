/* ffbri.h
 * Copyright (c) 2008 Moyea software.
 *
 * This file is part of FFBri.
 *
 * FFBri is a bridge interface to use FFmpeg. 
 * It is free software you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation either version 3 of
 * the License, or (at your option) any later version.
 *
 * FFbri is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this program . If not, see
 *
 * http://www.gnu.org/licenses/
 *
 */

#ifndef _FFMPEG_H_
#define _FFMPEG_H_

// from libavutil

#ifdef __cplusplus
extern "C" {
#endif

#define FFMPEG_VERSION 0,5,0,120 
#define FFMPEG_VERSION_STRING "0,5,0,120\0"

//typedef attribute_deprecated AVIOContext ByteIOContext;

#ifndef _MSC_VER

#define FFMPEG_CALL  
    
#else

#ifdef FFMPEG_EXPORT
#define FFMPEG_CALL  __declspec(dllexport)
#else
#define FFMPEG_CALL __declspec(dllimport)
#endif 

#endif



FFMPEG_CALL AVRational av_d2q_ffbri (double d, int max);

FFMPEG_CALL int64_t av_rescale_q_ffbri (int64_t a, AVRational bq, AVRational cq);

FFMPEG_CALL void  av_free_ffbri ( void* ptr );

FFMPEG_CALL void * av_malloc_ffbri ( unsigned int size );

FFMPEG_CALL void * av_mallocz_ffbri ( unsigned int size );

FFMPEG_CALL AVRational av_div_q_ffbri(AVRational b, AVRational c);

FFMPEG_CALL int av_find_nearest_q_idx_ffbri(AVRational q, const AVRational* q_list);


// from libavformat
//
//
FFMPEG_CALL int  url_fopen_ffbri (AVIOContext **s, const char *filename, int flags);

FFMPEG_CALL int  url_fclose_ffbri (AVIOContext *s);

FFMPEG_CALL AVOutputFormat *guess_format_ffbri (const char *short_name,
    const char *filename, const char *mime_type);

FFMPEG_CALL AVFormatContext* avformat_alloc_context_ffbri (void);

FFMPEG_CALL void  av_register_all_ffbri (void);

FFMPEG_CALL AVStream* avformat_new_stream_ffbri ( AVFormatContext* s, const AVCodec *c );

FFMPEG_CALL int av_open_input_file_ffbri( AVFormatContext **ic_ptr, 
    const char *filename, const char *fmtname, int reserve, AVDictionary **options );

FFMPEG_CALL int av_open_input_stream_ffbri(AVFormatContext **ic_ptr,
    AVIOContext *pb, const char *filename, const char *fmt, AVDictionary **ap);

FFMPEG_CALL int  av_set_parameters_ffbri ( AVFormatContext* s, AVDictionary* ap );

FFMPEG_CALL void  av_close_input_stream_ffbri (AVFormatContext *s);

FFMPEG_CALL void  av_close_input_file_ffbri ( AVFormatContext* s );

FFMPEG_CALL int  av_find_stream_info_ffbri ( AVFormatContext* ic );

FFMPEG_CALL void  av_init_packet_ffbri ( AVPacket* pkt );


// Demuxer
// 
FFMPEG_CALL int  av_read_frame_ffbri ( AVFormatContext* s, AVPacket* pkt );

FFMPEG_CALL int  av_seek_frame_ffbri ( AVFormatContext* s, 
    int stream_index, int64_t timestamp, int flags );

// Muxer.
//
FFMPEG_CALL int  av_write_header_ffbri ( AVFormatContext* s );

FFMPEG_CALL int  av_write_frame_ffbri ( AVFormatContext* s, AVPacket* pkt );

FFMPEG_CALL int  av_write_trailer_ffbri ( AVFormatContext* s );

FFMPEG_CALL int  av_interleaved_write_frame_ffbri ( AVFormatContext* s, AVPacket* pkt );

// from libavcodc
//
FFMPEG_CALL void  avcodec_register_all_ffbri ( void );

FFMPEG_CALL AVCodecContext* avcodec_alloc_context_ffbri (AVCodec *codec);
    
FFMPEG_CALL int  avcodec_get_context_defaults_ffbri ( AVCodecContext* s, const AVCodec* codec  );

FFMPEG_CALL AVFrame* avcodec_alloc_frame_ffbri (void);
    
FFMPEG_CALL AVPacket* avcodec_alloc_Packet_ffbri (void);

FFMPEG_CALL void  avcodec_get_frame_defaults_ffbri ( AVFrame* pic ); 

FFMPEG_CALL int  avcodec_decode_subtitle2_ffbri (AVCodecContext *avctx, 
        AVSubtitle *sub, int *got_sub_ptr, AVPacket *avpkt); 

FFMPEG_CALL int  avcodec_decode_video2_ffbri (AVCodecContext *avctx, 
        AVFrame *picture, int *got_picture_ptr, AVPacket *avpkt); 

FFMPEG_CALL int  avcodec_decode_audio3_ffbri (AVCodecContext *avctx, 
        int16_t *samples, int *frame_size_ptr, AVPacket *avpkt);

FFMPEG_CALL int  avcodec_decode_audio4_ffbri (AVCodecContext *avctx, 
        AVFrame *frame, int *got_frame_ptr, const AVPacket *avpkt);

FFMPEG_CALL int  avcodec_encode_audio_ffbri (AVCodecContext *avctx, 
    uint8_t *buf, int buf_size, const short *samples);
    
FFMPEG_CALL int avcodec_encode_audio2_ffbri (AVCodecContext *avctx, AVPacket *avpkt,
                          const AVFrame *frame, int *got_packet_ptr);
                          
FFMPEG_CALL int  avcodec_encode_video_ffbri ( AVCodecContext *avctx, 
    uint8_t *buf, int buf_size, const AVFrame *pict );
    
FFMPEG_CALL int avcodec_encode_video2_ffbri(AVCodecContext *avctx, 
    AVPacket *avpkt,const AVFrame *frame,int *got_packet_ptr);    

FFMPEG_CALL AVCodec* avcodec_find_decoder_ffbri ( enum AVCodecID id );

FFMPEG_CALL AVCodec* avcodec_find_encoder_ffbri ( enum AVCodecID id );

FFMPEG_CALL AVCodec *avcodec_find_encoder_by_name_ffbri(const char *name);

FFMPEG_CALL AVCodec *avcodec_find_decoder_by_name_ffbri(const char *name);

FFMPEG_CALL int  avcodec_open_ffbri ( AVCodecContext *avctx, AVCodec *codec,
														  AVDictionary **options );

FFMPEG_CALL int  avcodec_close_ffbri ( AVCodecContext* avctx );

FFMPEG_CALL int  avcodec_thread_init_ffbri (AVCodecContext *s, int thread_count);

FFMPEG_CALL void  avcodec_thread_free_ffbri (AVCodecContext *s);

FFMPEG_CALL int  avpicture_alloc_ffbri (AVPicture *picture, int pix_fmt, int width, int height);

FFMPEG_CALL void  avpicture_free_ffbri ( AVPicture* picture );

FFMPEG_CALL int  avpicture_fill_ffbri (AVPicture *picture, 
    uint8_t *ptr, int pix_fmt, int width, int height);

FFMPEG_CALL int  avpicture_get_size_ffbri ( int pix_fmt, int width, int height );

FFMPEG_CALL int  avpicture_deinterlace_ffbri (AVPicture *dst, 
    const AVPicture *src, int pix_fmt, int width, int height);

// chliu commented 2009-3-16 14:48:10
/*void deinterlace_bottom_field_ffbri (uint8_t *dst, int dst_wrap,
	const uint8_t *src1, int src_wrap, int width, int height);*/

// chliu modified  2010-2-24 11:10:08 //   for update to libswscale
// remove component_resample_ffbri, 
//
FFMPEG_CALL int  img_convert_ffbri ( AVPicture *dst, int dst_pix_fmt, int dst_width, int dst_height, 
        AVPicture *src, int src_pix_fmt, int src_width, int src_height);

FFMPEG_CALL void  *img_resample_init_ffbri ( int src_pix_fmt, int iwidth, int iheight, 
        int topBand, int bottomBand, int leftBand, int rightBand, 
        int dst_pix_fmt, int owidth, int oheight, 
        int padtop, int padbottom, int padleft, int padright );

FFMPEG_CALL int  img_resample_ffbri ( void *img_resample_ctx,  
        uint8_t* srcSlice[], int srcStride[],
        int srcSliceY, int srcSliceH, 
        uint8_t* dstSlice[], int dstStride[] ) ;

FFMPEG_CALL void  img_resample_close_ffbri ( void* img_resample_ctx );

FFMPEG_CALL ReSampleContext *av_audio_resample_init_ffbri (int output_channels, int input_channels,
                                        int output_rate, int input_rate,
                                        enum AVSampleFormat sample_fmt_out,
                                        enum AVSampleFormat sample_fmt_in,
                                        int filter_length, int log2_phase_count,
                                        int linear, double cutoff);

FFMPEG_CALL int  audio_resample_ffbri (ReSampleContext *s, 
    short *output, short *input, int nb_samples);

FFMPEG_CALL void  audio_resample_close_ffbri (ReSampleContext *s);

FFMPEG_CALL int img_resample_get_ffbri (void *c, int **inv_table, int *srcRange, int **table, int *dstRange, int *brightness, int *contrast, int *saturation);

FFMPEG_CALL int img_resample_set_ffbri (void *c, const int inv_table[4], int srcRange, const int table[4], int dstRange, int brightness, int contrast, int saturation); 

FFMPEG_CALL int av_dict_set_ffbri (AVDictionary **pm, const char *key, const char *value, int flags);

// andy added 2013-4-24 
// to richard required
FFMPEG_CALL AVDictionaryEntry * av_dict_get_ffbri(AVDictionary *m, const char *key, const AVDictionaryEntry *prev, int flags);

FFMPEG_CALL void av_dump_format_ffbri(AVFormatContext *ic,int index,const char *url,int is_output);

FFMPEG_CALL int av_reduce_ffbri(int *dst_num, int *dst_den,int64_t num, int64_t den, int64_t max);

FFMPEG_CALL void av_log_set_callback_ffbri(void (*callback)(void*, int, const char*, va_list));

FFMPEG_CALL void av_free_packet_ffbri(AVPacket *pkt);

FFMPEG_CALL int avcodec_encode_subtitle_ffbri(AVCodecContext *avctx, uint8_t *buf, int buf_size,const AVSubtitle *sub);

FFMPEG_CALL int av_opt_set_ffbri ( void *obj, const char *name, const char *val, int search_flags );

FFMPEG_CALL struct SwrContext *swr_alloc_set_opts_ffbri(struct SwrContext *s,
                                      int64_t out_ch_layout, enum AVSampleFormat out_sample_fmt, int out_sample_rate,
                                      int64_t  in_ch_layout, enum AVSampleFormat  in_sample_fmt, int  in_sample_rate,
                                      int log_offset, void *log_ctx);
                                      
FFMPEG_CALL int swr_init_ffbri(struct SwrContext *s);
                                      
FFMPEG_CALL void swr_free_ffbri(struct SwrContext **s);                                      

FFMPEG_CALL int swr_convert_frame_ffbri(struct SwrContext *swr,
                      AVFrame *output, const AVFrame *input);

FFMPEG_CALL int avcodec_copy_context_ffbri(	AVCodecContext *dest,const AVCodecContext *src);

FFMPEG_CALL void avformat_free_context_ffbri(AVFormatContext *s);

FFMPEG_CALL int av_compare_ts_ffbri(int64_t ts_a,AVRational tb_a,int64_t ts_b,AVRational tb_b);

FFMPEG_CALL int avformat_alloc_output_context2_ffbri(AVFormatContext **ctx,AVOutputFormat *oformat,const char *format_name,const char *filename);

FFMPEG_CALL int64_t av_rescale_q_rnd_ffbri(int64_t a,AVRational bq,AVRational cq,enum AVRounding rnd);
//damon
FFMPEG_CALL int avcodec_send_packet_ffbri(AVCodecContext *c,AVPacket *packet);
    
FFMPEG_CALL int avcodec_receive_frame_ffbri(AVCodecContext *c,AVFrame* frame);
    
FFMPEG_CALL int av_image_get_buffer_size_ffbri(enum AVPixelFormat pix_fmt, int width, int height, int align);

FFMPEG_CALL int av_image_fill_arrays_ffbri(uint8_t *dst_data[4], int dst_linesize[4],
                             const uint8_t *src,enum AVPixelFormat pix_fmt, int width, int height, int align);

FFMPEG_CALL int av_image_copy_to_buffer_ffbri(uint8_t *dst, int dst_size,
                                const uint8_t * const src_data[4], const int src_linesize[4],
                                enum AVPixelFormat pix_fmt, int width, int height, int align);
    
FFMPEG_CALL struct SwsContext * sws_getCachedContext_ffbri(struct SwsContext *context,
                                            int srcW, int srcH, enum AVPixelFormat srcFormat,
                                            int dstW, int dstH, enum AVPixelFormat dstFormat,
                                            int flags, SwsFilter *srcFilter,
                                            SwsFilter *dstFilter, const double *param);
    
FFMPEG_CALL int sws_scale_ffbri(struct SwsContext *c, const uint8_t *const srcSlice[],
                  const int srcStride[], int srcSliceY, int srcSliceH,
                                 uint8_t *const dst[], const int dstStride[]);
    
FFMPEG_CALL void av_log_Meta_ffbri(AVDictionaryEntry *t);
//chenhb 20160705
FFMPEG_CALL int avformat_flush_ffbri(AVFormatContext *s);

FFMPEG_CALL void avcodec_free_frame_ffbri(AVFrame **frame);
    
#ifdef __cplusplus
}
#endif

#endif  // end #ifndef __FFMPEG_H_



