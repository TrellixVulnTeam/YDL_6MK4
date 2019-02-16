/* ffbri.c
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
 
#define USING_LIBSWSCALE

#include "libavcodec/avcodec.h" 
#include "libavformat/avformat.h"
#include "libswscale/swscale.h"
#include "libavutil/imgutils.h"


#define FFBRI_EXPORT

#include "ffbri.h"

FFMPEG_CALL AVRational av_d2q_ffbri (double d, int max)
{
	return av_d2q (d,max);
}


FFMPEG_CALL int64_t av_rescale_q_ffbri (int64_t a, AVRational bq, AVRational cq)
{
    return av_rescale_q (a, bq, cq);
}

FFMPEG_CALL void av_free_ffbri ( void* ptr )
{
    return av_free ( ptr );
}

FFMPEG_CALL void* av_malloc_ffbri ( unsigned int size )
{
    return av_malloc (size );
}

FFMPEG_CALL void* av_mallocz_ffbri ( unsigned int size )
{
    return av_mallocz (size );
}


// from libavformat
//
FFMPEG_CALL AVFormatContext* avformat_alloc_context_ffbri (void)
{
    return avformat_alloc_context ();
}

FFMPEG_CALL void av_register_all_ffbri (void)
{
    return av_register_all ();
}

FFMPEG_CALL AVStream* avformat_new_stream_ffbri ( AVFormatContext* s, const AVCodec *c )
{
    return avformat_new_stream ( s, c );
}


FFMPEG_CALL int av_open_input_file_ffbri( AVFormatContext **ic_ptr, 
    const char *filename, const char *fmtname, int reserve, AVDictionary **ap )
{
    AVInputFormat* fmt = NULL;

    if (fmtname) fmt = av_find_input_format (fmtname);

    return avformat_open_input ( ic_ptr, filename, fmt, ap );
}

// chliu added 2009-12-17 15:08:43
// only for our custom's byte IO 
// such dvd reader.
#if 0 // delete by jwg,20170622
FFMPEG_CALL int av_open_input_stream_ffbri(AVFormatContext **ic_ptr,
    AVIOContext *pb, const char *filename, 
    const char *fmtname, AVDictionary **ap)
{ 
    int err = 0;
    AVInputFormat* fmt = NULL;

    //if ( NULL == pb ) goto fail;             

    if (!fmtname) 
        fmt = av_find_input_format ("mpeg");
    else 
        fmt = av_find_input_format (fmtname);

    /* if still no format found, error */
    if (!fmt) {
        err = -1;
        goto fail;
    }

    if (ffio_init_context( pb, pb->buffer, pb->buffer_size,
                      0, pb->opaque,
                      pb->read_packet, NULL, pb->seek ) < 0) 
    {
        err = -2;
        goto fail;
    } 

    err = avformat_open_input(ic_ptr, filename, fmt, ap);
    if (!err) return 0;

 fail:

    *ic_ptr = NULL;

    return err; 
}
#endif
FFMPEG_CALL void av_close_input_stream_ffbri (AVFormatContext *s)
{ 
    return avformat_close_input ( &s );
} 

FFMPEG_CALL void av_close_input_file_ffbri ( AVFormatContext* s )
{
    return avformat_close_input( &s ) ;
}

FFMPEG_CALL int av_set_parameters_ffbri ( AVFormatContext* s, AVDictionary* ap )
{
    return 0;   
}

FFMPEG_CALL int av_find_stream_info_ffbri ( AVFormatContext* ic )
{
    return avformat_find_stream_info ( ic, NULL );
}

FFMPEG_CALL void av_init_packet_ffbri ( AVPacket* pkt )
{
    return av_init_packet ( pkt );
}


// Demuxer
// 
FFMPEG_CALL int av_read_frame_ffbri ( AVFormatContext* s, AVPacket* pkt )
{
    return av_read_frame ( s,  pkt );
}

FFMPEG_CALL int av_seek_frame_ffbri ( AVFormatContext* s, 
    int stream_index, int64_t timestamp, int flags )
{
    return av_seek_frame ( s, stream_index, timestamp, flags );
}

// Muxer.
//
FFMPEG_CALL int av_write_header_ffbri ( AVFormatContext* s )
{
    return avformat_write_header ( s, NULL );
}

FFMPEG_CALL int av_write_frame_ffbri ( AVFormatContext* s, AVPacket* pkt )
{
    return av_write_frame ( s,  pkt );
}

FFMPEG_CALL int av_write_trailer_ffbri ( AVFormatContext* s )
{
    return av_write_trailer ( s );
}

FFMPEG_CALL int av_interleaved_write_frame_ffbri ( AVFormatContext* s, AVPacket* pkt )
{
    return av_interleaved_write_frame ( s,  pkt );
}

// from libavcodc
//
FFMPEG_CALL void avcodec_register_all_ffbri ( void )
{
    return avcodec_register_all ();
}

FFMPEG_CALL AVCodecContext* avcodec_alloc_context_ffbri (AVCodec *codec)
{
    return avcodec_alloc_context3 (codec);
}
    
FFMPEG_CALL int avcodec_get_context_defaults_ffbri ( AVCodecContext* s, 
										 const AVCodec *codec )
{
    return avcodec_get_context_defaults3 ( s, codec );
}

FFMPEG_CALL AVFrame* avcodec_alloc_frame_ffbri (void)
{
    return av_frame_alloc ();
}
FFMPEG_CALL AVPacket* avcodec_alloc_Packet_ffbri (void)
{
    return av_packet_alloc();
}
FFMPEG_CALL void avcodec_get_frame_defaults_ffbri ( AVFrame* pic )
{
    return  av_frame_unref ( pic );
} 

FFMPEG_CALL int avcodec_decode_subtitle2_ffbri (AVCodecContext *avctx, 
        AVSubtitle *sub, int *got_sub_ptr, AVPacket *avpkt)
{
    return avcodec_decode_subtitle2 ( avctx, sub, got_sub_ptr, avpkt ); 
} 

FFMPEG_CALL int avcodec_decode_video2_ffbri (AVCodecContext *avctx, 
        AVFrame *picture, int *got_picture_ptr, AVPacket *avpkt)
{
    return avcodec_decode_video2 ( avctx, picture, got_picture_ptr, avpkt );
} 

FFMPEG_CALL int avcodec_decode_audio3_ffbri (AVCodecContext *avctx, 
        int16_t *samples, int *frame_size_ptr, AVPacket *avpkt)
{
    return avcodec_decode_audio4 ( avctx, samples, frame_size_ptr, avpkt);
} 

FFMPEG_CALL int avcodec_decode_audio4_ffbri (AVCodecContext *avctx, 
        AVFrame *frame, int *got_frame_ptr, const AVPacket *avpkt)
{
    return avcodec_decode_audio4 ( avctx, frame, got_frame_ptr, avpkt); 
} 

FFMPEG_CALL int avcodec_encode_audio_ffbri (AVCodecContext *avctx, 
        uint8_t *buf, int buf_size, const short *samples)
{
    return avcodec_encode_audio2 ( avctx, buf, buf_size, samples);
}

FFMPEG_CALL int avcodec_encode_audio2_ffbri (AVCodecContext *avctx, AVPacket *avpkt,
                          const AVFrame *frame, int *got_packet_ptr)
{
    return avcodec_encode_audio2 (avctx, avpkt, frame, got_packet_ptr);
}                          

FFMPEG_CALL int avcodec_encode_video_ffbri ( AVCodecContext *avctx, 
        uint8_t *buf, int buf_size, const AVFrame *pict )
{
    return avcodec_encode_video2 (avctx, buf, buf_size, pict );
}

FFMPEG_CALL int avcodec_encode_video2_ffbri(AVCodecContext *avctx, AVPacket *avpkt,const AVFrame *frame,int *got_packet_ptr)
{
    return avcodec_encode_video2 ( avctx, avpkt, frame, got_packet_ptr );
}

FFMPEG_CALL AVCodec* avcodec_find_decoder_ffbri (enum AVCodecID id )
{
    return avcodec_find_decoder (id );
}

FFMPEG_CALL AVCodec* avcodec_find_encoder_ffbri (enum AVCodecID id )
{
    return avcodec_find_encoder (id );
}

FFMPEG_CALL int avcodec_open_ffbri ( AVCodecContext *avctx, AVCodec *codec, AVDictionary **options )
{
    return avcodec_open2 (avctx, codec, options);
}

FFMPEG_CALL int avcodec_close_ffbri ( AVCodecContext* avctx )
{
    return avcodec_close ( avctx );
}

FFMPEG_CALL int avcodec_thread_init_ffbri (AVCodecContext *s, int thread_count)
{
    return 0;//avcodec_thread_init (s, thread_count);
}

FFMPEG_CALL void avcodec_thread_free_ffbri (AVCodecContext *s)
{

    return ;//avcodec_thread_free (s);

}

FFMPEG_CALL int avpicture_alloc_ffbri (AVPicture *picture, int pix_fmt, int width, int height)
{
    return avpicture_alloc (picture, pix_fmt, width, height);
}
FFMPEG_CALL void avpicture_free_ffbri ( AVPicture* picture )
{
    return avpicture_free ( picture );
}

FFMPEG_CALL int avpicture_fill_ffbri (AVPicture *picture, uint8_t *ptr, int pix_fmt, int width, int height)
{
    return avpicture_fill ( picture, ptr, pix_fmt, width, height);
}

FFMPEG_CALL int avpicture_get_size_ffbri ( int pix_fmt, int width, int height )
{
    return avpicture_get_size (pix_fmt, width, height );
}

FFMPEG_CALL int avpicture_deinterlace_ffbri (AVPicture *dst, const AVPicture *src, int pix_fmt, int width, int height)
{
    return avpicture_deinterlace_ffbri ( dst, src, pix_fmt, width, height);
}

/* chliu commented 2009-3-16 14:56:16
void deinterlace_bottom_field_ffbri (uint8_t *dst, int dst_wrap, const uint8_t *src1, int src_wrap, int width, int height)
{
    return deinterlace_bottom_field ( dst, dst_wrap, src1, src_wrap, width, height);
}*/

FFMPEG_CALL int img_convert_ffbri ( AVPicture *dst, int dst_pix_fmt, int dst_width, int dst_height,
        AVPicture *src, int src_pix_fmt, int src_width, int src_height) 
{
#ifdef USING_LIBSWSCALE
    int ret = 0;

    void* img_resample_ctx = sws_getContext(
            src_width,
            src_height,
            src_pix_fmt,
            dst_width,
            dst_height,
            dst_pix_fmt,
            SWS_BICUBIC, NULL, NULL, NULL); 
    if ( NULL == img_resample_ctx ) return -1;

    ret = sws_scale ( img_resample_ctx, src->data, src->linesize,
        0, src_height, dst->data, dst->linesize ); 

    sws_freeContext ( img_resample_ctx );

    return ret ;

#else
    return img_convert ( dst, dst_pix_fmt, src, src_pix_fmt, src_width, src_height);
#endif
}


FFMPEG_CALL void *img_resample_init_ffbri ( int src_pix_fmt, int iwidth, int iheight, 
        int topBand, int bottomBand, int leftBand, int rightBand, 
        int dst_pix_fmt, int owidth, int oheight, 
        int padtop, int padbottom, int padleft, int padright )
{
#ifdef  USING_LIBSWSCALE 
    return sws_getContext(
            iwidth - (leftBand + rightBand),
            iheight - (topBand + bottomBand),
            src_pix_fmt,
            owidth - (padleft + padright),
            oheight - (padtop + padbottom),
            dst_pix_fmt,
            SWS_BICUBIC, NULL, NULL, NULL); 
#else
    return img_resample_full_init (owidth, oheight, iwidth, iheight, 
            topBand, bottomBand, leftBand, rightBand, 
            padtop, padbottom, padleft, padright );
#endif
} 

FFMPEG_CALL int img_resample_ffbri ( void *img_resample_ctx,  
        uint8_t* srcSlice[], int srcStride[],
        int srcSliceY, int srcSliceH, 
        uint8_t* dstSlice[], int dstStride[] )
{
#ifdef  USING_LIBSWSCALE
    return sws_scale ( img_resample_ctx, srcSlice, srcStride,
        srcSliceY, srcSliceH, dstSlice, dstStride ); 
#else
    return img_resample ( img_resample_ctx, output, input);
#endif
}

FFMPEG_CALL void img_resample_close_ffbri ( void* img_resample_ctx )
{
#ifdef  USING_LIBSWSCALE
    return sws_freeContext ( img_resample_ctx ); 
#else
    return img_resample_close ( img_resample_ctx );
#endif
}

// chliu added 2010-7-5 15:01:35
FFMPEG_CALL int img_resample_set_ffbri (void *c, const int inv_table[4], int srcRange, const int table[4], int dstRange, int brightness, int contrast, int saturation) 
{
    return sws_setColorspaceDetails(c, inv_table, srcRange, 
            table, dstRange, brightness, contrast, saturation);
}

FFMPEG_CALL int img_resample_get_ffbri (void *c, int **inv_table, int *srcRange, int **table, int *dstRange, int *brightness, int *contrast, int *saturation)
{
    return sws_getColorspaceDetails(c, inv_table, 
            srcRange, table, 
            dstRange, brightness, contrast, saturation);
}


FFMPEG_CALL ReSampleContext *av_audio_resample_init_ffbri (int output_channels, int input_channels,
                                        int output_rate, int input_rate,
                                        enum AVSampleFormat sample_fmt_out,
                                        enum AVSampleFormat sample_fmt_in,
                                        int filter_length, int log2_phase_count,
                                        int linear, double cutoff)
{
    return av_audio_resample_init (output_channels, input_channels, 
        output_rate, input_rate, sample_fmt_out, sample_fmt_in, 
        filter_length, log2_phase_count, linear, cutoff );
}

FFMPEG_CALL int audio_resample_ffbri (ReSampleContext *s, short *output, short *input, int nb_samples)
{
    return audio_resample (s, output, input, nb_samples);
}

FFMPEG_CALL void audio_resample_close_ffbri (ReSampleContext *s)
{
    return audio_resample_close (s);
}

FFMPEG_CALL int url_fopen_ffbri (AVIOContext **s, const char *filename, int flags)
{
    return avio_open (s, filename, flags );
}


FFMPEG_CALL int url_fclose_ffbri (AVIOContext *s)
{
    return avio_close (s); 
}

FFMPEG_CALL AVOutputFormat *guess_format_ffbri (const char *short_name,
    const char *filename, const char *mime_type)
{
#ifdef USING_LIBSWSCALE
    return av_guess_format ( short_name, filename, mime_type );
#else
    return guess_format ( short_name, filename, mime_type );
#endif

}

FFMPEG_CALL AVCodec *avcodec_find_encoder_by_name_ffbri(const char *name)
{
    return avcodec_find_encoder_by_name ( name );
}

FFMPEG_CALL AVCodec *avcodec_find_decoder_by_name_ffbri(const char *name)
{
    return avcodec_find_decoder_by_name ( name );
}

FFMPEG_CALL int av_dict_set_ffbri (AVDictionary **pm, const char *key, const char *value, int flags)
{
    return av_dict_set ( pm, key, value, flags );
}

// andy added 2013-4-24 
// to richard required
FFMPEG_CALL AVDictionaryEntry * av_dict_get_ffbri(AVDictionary *m, const char *key, const AVDictionaryEntry *prev, int flags)
{
    return av_dict_get ( m, key, prev, flags );
}

FFMPEG_CALL void av_dump_format_ffbri(AVFormatContext *ic,int index,const char *url,int is_output)
{
    return av_dump_format ( ic, index, url, is_output );
}

FFMPEG_CALL int av_reduce_ffbri(int *dst_num, int *dst_den,int64_t num, int64_t den, int64_t max)
{
    return av_reduce ( dst_num, dst_den, num, den, max );
}


FFMPEG_CALL AVRational av_div_q_ffbri(AVRational b, AVRational c)
{
		return av_div_q ( b, c );
}

FFMPEG_CALL int av_find_nearest_q_idx_ffbri(AVRational q, const AVRational* q_list)
{
	return 	av_find_nearest_q_idx ( q, q_list );
}

FFMPEG_CALL void av_log_set_callback_ffbri(void (*callback)(void*, int, const char*, va_list))
{
    return av_log_set_callback ( callback );
}

FFMPEG_CALL void av_free_packet_ffbri(AVPacket *pkt)
{
    av_free_packet ( pkt );
}

FFMPEG_CALL int avcodec_encode_subtitle_ffbri(AVCodecContext *avctx, uint8_t *buf, 
                                  int buf_size, const AVSubtitle *sub )
{
    return avcodec_encode_subtitle ( avctx, buf, buf_size, sub );
}


FFMPEG_CALL int av_opt_set_ffbri ( void *obj, const char *name, const char *val, int search_flags)
{
	return av_dict_set ( obj, name, val, search_flags );
}

FFMPEG_CALL struct SwrContext *swr_alloc_set_opts_ffbri(struct SwrContext *s,
                                      int64_t out_ch_layout, enum AVSampleFormat out_sample_fmt, int out_sample_rate,
                                      int64_t  in_ch_layout, enum AVSampleFormat  in_sample_fmt, int  in_sample_rate,
                                      int log_offset, void *log_ctx)
{
    return swr_alloc_set_opts_ffbri(s, out_ch_layout, out_sample_fmt, out_sample_rate,
                                 in_ch_layout, in_sample_fmt, in_sample_rate,
                                 log_offset, log_ctx);
}

FFMPEG_CALL int avcodec_send_packet_ffbri(AVCodecContext *c,AVPacket *packet){
    
    return avcodec_send_packet(c, packet);
}
FFMPEG_CALL int avcodec_receive_frame_ffbri(AVCodecContext *c,AVFrame* frame){
    return avcodec_receive_frame(c,frame);
}

FFMPEG_CALL int av_image_get_buffer_size_ffbri(enum AVPixelFormat pix_fmt, int width, int height, int align){
    
    return av_image_get_buffer_size(AV_PIX_FMT_RGB24, width, height, align);
}

FFMPEG_CALL int av_image_fill_arrays_ffbri(uint8_t *dst_data[4], int dst_linesize[4],
                                           const uint8_t *src,enum AVPixelFormat pix_fmt, int width, int height, int align)
{
    return av_image_fill_arrays(dst_data, dst_linesize, src, pix_fmt, width, height, align);
}

FFMPEG_CALL int av_image_copy_to_buffer_ffbri(uint8_t *dst, int dst_size,
                                              const uint8_t * const src_data[4], const int src_linesize[4],
                                              enum AVPixelFormat pix_fmt, int width, int height, int align){
    return av_image_copy_to_buffer(dst, dst_size, src_data, src_linesize, AV_PIX_FMT_RGB24, width, height, align);
}

FFMPEG_CALL struct SwsContext * sws_getCachedContext_ffbri(struct SwsContext *context,
                                                           int srcW, int srcH, enum AVPixelFormat srcFormat,
                                                           int dstW, int dstH, enum AVPixelFormat dstFormat,
                                                           int flags, SwsFilter *srcFilter,
                                                           SwsFilter *dstFilter, const double *param){
    
    return sws_getContext(srcW, srcH, AV_PIX_FMT_YUV420P, dstW, dstH, AV_PIX_FMT_RGB24, flags, srcFilter, dstFilter, param);
}
FFMPEG_CALL int sws_scale_ffbri(struct SwsContext *c, const uint8_t *const srcSlice[],
                                const int srcStride[], int srcSliceY, int srcSliceH,
                                uint8_t *const dst[], const int dstStride[]){
    return sws_scale_ffbri(c, srcSlice, srcStride, srcSliceY, srcSliceH, dst, dstStride);
}
/*delete by jwg,20170622
FFMPEG_CALL int swr_init_ffbri(struct SwrContext *s)
{
    return swr_init(s);
}                                    

FFMPEG_CALL void swr_free_ffbri(struct SwrContext **s)
{
    swr_free(s);
}

FFMPEG_CALL int swr_convert_frame_ffbri(struct SwrContext *swr,
                      AVFrame *output, const AVFrame *input)
{
    return swr_convert_frame(swr, output, input);
}                      
*/
//johnson add :concat
FFMPEG_CALL int avcodec_copy_context_ffbri(	AVCodecContext *dest,const AVCodecContext *src)
{
    return avcodec_copy_context(dest,src);
}

FFMPEG_CALL void avformat_free_context_ffbri(AVFormatContext *s)
{
    avformat_free_context(s);
}

FFMPEG_CALL int av_compare_ts_ffbri(int64_t ts_a,AVRational tb_a,int64_t ts_b,AVRational tb_b)	
{
    return av_compare_ts(ts_a,tb_a,ts_b,tb_b);
}

FFMPEG_CALL int avformat_alloc_output_context2_ffbri(AVFormatContext **ctx,AVOutputFormat *oformat,const char *format_name,const char *filename)
{
    return avformat_alloc_output_context2(ctx,oformat,format_name,filename);
}


FFMPEG_CALL int64_t av_rescale_q_rnd_ffbri(int64_t a,AVRational bq,AVRational cq,enum AVRounding rnd)
{
    return av_rescale_q_rnd(a,bq,cq,rnd);
}

FFMPEG_CALL int avformat_flush_ffbri(AVFormatContext *s)
{
	return avformat_flush(s);
}

FFMPEG_CALL void avcodec_free_frame_ffbri(AVFrame **frame)
{
	av_frame_free(frame);
}                
FFMPEG_CALL void av_log_Meta_ffbri(AVDictionaryEntry *t){
    av_log(NULL, AV_LOG_DEBUG, "%s: %s", t->key, t->value);
}
// end


