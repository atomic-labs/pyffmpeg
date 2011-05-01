# -*- coding: utf-8 -*-

"""
##################################################################################
# PyFFmpeg v2.2 alpha 1
#
# Copyright (C) 2011 KATO Kanryu <k.kanryu@gmail.com>
#
##################################################################################
#  This file is distibuted under LGPL-3.0
#  See COPYING file attached.
##################################################################################
"""


##################################################################################
#  Declaration and imports
##################################################################################
from avutil cimport *

##################################################################################
# ok libavcodec   52.113. 2
cdef extern from "libavcodec/avcodec.h":
    # use an unamed enum for defines
    cdef enum:
        CODEC_FLAG_QSCALE               = 0x0002  #< Use fixed qscale.
        CODEC_FLAG_4MV                  = 0x0004  #< 4 MV per MB allowed / advanced prediction for H.263.
        CODEC_FLAG_QPEL                 = 0x0010  #< Use qpel MC.
        CODEC_FLAG_GMC                  = 0x0020  #< Use GMC.
        CODEC_FLAG_MV0                  = 0x0040  #< Always try a MB with MV=<0,0>.
        CODEC_FLAG_PART                 = 0x0080  #< Use data partitioning.
        # * The parent program guarantees that the input for B-frames containing
        # * streams is not written to for at least s->max_b_frames+1 frames, if
        # * this is not set the input will be copied.
        CODEC_FLAG_INPUT_PRESERVED      = 0x0100
        CODEC_FLAG_PASS1                = 0x0200   #< Use internal 2pass ratecontrol in first pass mode.
        CODEC_FLAG_PASS2                = 0x0400   #< Use internal 2pass ratecontrol in second pass mode.
        CODEC_FLAG_EXTERN_HUFF          = 0x1000   #< Use external Huffman table (for MJPEG).
        CODEC_FLAG_GRAY                 = 0x2000   #< Only decode/encode grayscale.
        CODEC_FLAG_EMU_EDGE             = 0x4000   #< Don't draw edges.
        CODEC_FLAG_PSNR                 = 0x8000   #< error[?] variables will be set during encoding.
        CODEC_FLAG_TRUNCATED            = 0x00010000 #< Input bitstream might be truncated at a random location instead of only at frame boundaries.
        CODEC_FLAG_NORMALIZE_AQP        = 0x00020000 #< Normalize adaptive quantization.
        CODEC_FLAG_INTERLACED_DCT       = 0x00040000 #< Use interlaced DCT.
        CODEC_FLAG_LOW_DELAY            = 0x00080000 #< Force low delay.
        CODEC_FLAG_ALT_SCAN             = 0x00100000 #< Use alternate scan.
        CODEC_FLAG_GLOBAL_HEADER        = 0x00400000 #< Place global headers in extradata instead of every keyframe.
        CODEC_FLAG_BITEXACT             = 0x00800000 #< Use only bitexact stuff (except (I)DCT).
        # Fx : Flag for h263+ extra options 
        CODEC_FLAG_AC_PRED              = 0x01000000 #< H.263 advanced intra coding / MPEG-4 AC prediction
        CODEC_FLAG_H263P_UMV            = 0x02000000 #< unlimited motion vector
        CODEC_FLAG_CBP_RD               = 0x04000000 #< Use rate distortion optimization for cbp.
        CODEC_FLAG_QP_RD                = 0x08000000 #< Use rate distortion optimization for qp selectioon.
        CODEC_FLAG_H263P_AIV            = 0x00000008 #< H.263 alternative inter VLC
        CODEC_FLAG_OBMC                 = 0x00000001 #< OBMC
        CODEC_FLAG_LOOP_FILTER          = 0x00000800 #< loop filter
        CODEC_FLAG_H263P_SLICE_STRUCT   = 0x10000000
        CODEC_FLAG_INTERLACED_ME        = 0x20000000 #< interlaced motion estimation
        CODEC_FLAG_SVCD_SCAN_OFFSET     = 0x40000000 #< Will reserve space for SVCD scan offset user data.
        CODEC_FLAG_CLOSED_GOP           = 0x80000000
        CODEC_FLAG2_FAST                = 0x00000001 #< Allow non spec compliant speedup tricks.
        CODEC_FLAG2_STRICT_GOP          = 0x00000002 #< Strictly enforce GOP size.
        CODEC_FLAG2_NO_OUTPUT           = 0x00000004 #< Skip bitstream encoding.
        CODEC_FLAG2_LOCAL_HEADER        = 0x00000008 #< Place global headers at every keyframe instead of in extradata.
        CODEC_FLAG2_BPYRAMID            = 0x00000010 #< H.264 allow B-frames to be used as references.
        CODEC_FLAG2_WPRED               = 0x00000020 #< H.264 weighted biprediction for B-frames
        CODEC_FLAG2_MIXED_REFS          = 0x00000040 #< H.264 one reference per partition, as opposed to one reference per macroblock
        CODEC_FLAG2_8X8DCT              = 0x00000080 #< H.264 high profile 8x8 transform
        CODEC_FLAG2_FASTPSKIP           = 0x00000100 #< H.264 fast pskip
        CODEC_FLAG2_AUD                 = 0x00000200 #< H.264 access unit delimiters
        CODEC_FLAG2_BRDO                = 0x00000400 #< B-frame rate-distortion optimization
        CODEC_FLAG2_INTRA_VLC           = 0x00000800 #< Use MPEG-2 intra VLC table.
        CODEC_FLAG2_MEMC_ONLY           = 0x00001000 #< Only do ME/MC (I frames -> ref, P frame -> ME+MC).
        CODEC_FLAG2_DROP_FRAME_TIMECODE = 0x00002000 #< timecode is in drop frame format.
        CODEC_FLAG2_SKIP_RD             = 0x00004000 #< RD optimal MB level residual skipping
        CODEC_FLAG2_CHUNKS              = 0x00008000 #< Input bitstream might be truncated at a packet boundaries instead of only at frame boundaries.
        CODEC_FLAG2_NON_LINEAR_QUANT    = 0x00010000 #< Use MPEG-2 nonlinear quantizer.
        CODEC_FLAG2_BIT_RESERVOIR       = 0x00020000 #< Use a bit reservoir when encoding if possible
        CODEC_FLAG2_MBTREE              = 0x00040000 #< Use macroblock tree ratecontrol (x264 only)
        CODEC_FLAG2_PSY                 = 0x00080000 #< Use psycho visual optimizations.
        CODEC_FLAG2_SSIM                = 0x00100000 #< Compute SSIM during encoding, error[] values are undefined.
        CODEC_FLAG2_INTRA_REFRESH       = 0x00200000 #< Use periodic insertion of intra blocks instead of keyframes.

        # codec capabilities
        CODEC_CAP_DRAW_HORIZ_BAND       = 0x0001 #< Decoder can use draw_horiz_band callback.
        CODEC_CAP_DR1                   = 0x0002 
        CODEC_CAP_PARSE_ONLY            = 0x0004
        CODEC_CAP_TRUNCATED             = 0x0008
        CODEC_CAP_HWACCEL               = 0x0010
        CODEC_CAP_DELAY                 = 0x0020
        CODEC_CAP_SMALL_LAST_FRAME      = 0x0040
        CODEC_CAP_HWACCEL_VDPAU         = 0x0080
        CODEC_CAP_SUBFRAMES             = 0x0100
        CODEC_CAP_EXPERIMENTAL          = 0x0200
        CODEC_CAP_CHANNEL_CONF          = 0x0400
        CODEC_CAP_NEG_LINESIZES         = 0x0800
        CODEC_CAP_FRAME_THREADS         = 0x1000

        # AVFrame pict_type values
        FF_I_TYPE            = 1         #< Intra
        FF_P_TYPE            = 2         #< Predicted
        FF_B_TYPE            = 3         #< Bi-dir predicted
        FF_S_TYPE            = 4         #< S(GMC)-VOP MPEG4
        FF_SI_TYPE           = 5         #< Switching Intra
        FF_SP_TYPE           = 6         #< Switching Predicte
        FF_BI_TYPE           = 7

        # AVFrame mb_type values
        #The following defines may change, don't expect compatibility if you use them.
        #Note bits 24-31 are reserved for codec specific use (h264 ref0, mpeg1 0mv, ...)
        MB_TYPE_INTRA4x4   = 0x0001
        MB_TYPE_INTRA16x16 = 0x0002 #FIXME H.264-specific
        MB_TYPE_INTRA_PCM  = 0x0004 #FIXME H.264-specific
        MB_TYPE_16x16      = 0x0008
        MB_TYPE_16x8       = 0x0010
        MB_TYPE_8x16       = 0x0020
        MB_TYPE_8x8        = 0x0040
        MB_TYPE_INTERLACED = 0x0080
        MB_TYPE_DIRECT2    = 0x0100 #FIXME
        MB_TYPE_ACPRED     = 0x0200
        MB_TYPE_GMC        = 0x0400
        MB_TYPE_SKIP       = 0x0800
        MB_TYPE_P0L0       = 0x1000
        MB_TYPE_P1L0       = 0x2000
        MB_TYPE_P0L1       = 0x4000
        MB_TYPE_P1L1       = 0x8000
        MB_TYPE_L0         = (MB_TYPE_P0L0 | MB_TYPE_P1L0)
        MB_TYPE_L1         = (MB_TYPE_P0L1 | MB_TYPE_P1L1)
        MB_TYPE_L0L1       = (MB_TYPE_L0   | MB_TYPE_L1)
        MB_TYPE_QUANT      = 0x00010000
        MB_TYPE_CBP        = 0x00020000
        
        # AVCodecContext error_concealment values
        FF_EC_GUESS_MV       = 1
        FF_EC_DEBLOCK        = 2
        
        # AVCodecContext debug values
        FF_DEBUG_PICT_INFO   = 1
        FF_DEBUG_RC          = 2
        FF_DEBUG_BITSTREAM   = 4
        FF_DEBUG_MB_TYPE     = 8
        FF_DEBUG_QP          = 16
        FF_DEBUG_MV          = 32
        FF_DEBUG_DCT_COEFF   = 0x00000040
        FF_DEBUG_SKIP        = 0x00000080
        FF_DEBUG_STARTCODE   = 0x00000100
        FF_DEBUG_PTS         = 0x00000200
        FF_DEBUG_ER          = 0x00000400
        FF_DEBUG_MMCO        = 0x00000800
        FF_DEBUG_BUGS        = 0x00001000
        FF_DEBUG_VIS_QP      = 0x00002000
        FF_DEBUG_VIS_MB_TYPE = 0x00004000
        FF_DEBUG_BUFFERS     = 0x00008000
        
        # AVCodecContext debug_mv values
        FF_DEBUG_VIS_MV_P_FOR  = 0x00000001 #< visualize forward predicted MVs of P frames
        FF_DEBUG_VIS_MV_B_FOR  = 0x00000002 #< visualize forward predicted MVs of B frames
        FF_DEBUG_VIS_MV_B_BACK = 0x00000004 #< visualize backward predicted MVs of B frames
        
        # AVCodecContex dtg_active_format values
        FF_DTG_AFD_SAME        = 8
        FF_DTG_AFD_4_3         = 9        #< 4:3
        FF_DTG_AFD_16_9        = 10       #< 16:9
        FF_DTG_AFD_14_9        = 11       #< 14:9
        FF_DTG_AFD_4_3_SP_14_9 = 13 
        FF_DTG_AFD_16_9_SP_14_9= 14
        FF_DTG_AFD_SP_4_3      = 15

        # AVCodecContex profile values
        FF_PROFILE_UNKNOWN     = -99
    
        FF_PROFILE_AAC_MAIN    = 0
        FF_PROFILE_AAC_LOW     = 1
        FF_PROFILE_AAC_SSR     = 2
        FF_PROFILE_AAC_LTP     = 3

        FF_PROFILE_H264_BASELINE  = 66
        FF_PROFILE_H264_MAIN      = 77
        FF_PROFILE_H264_EXTENDED  = 88
        FF_PROFILE_H264_HIGH      = 100
        FF_PROFILE_H264_HIGH_10   = 110
        FF_PROFILE_H264_HIGH_422  = 122
        FF_PROFILE_H264_HIGH_444  = 244
        FF_PROFILE_H264_CAVLC_444 = 44
        
        FF_LEVEL_UNKNOWN       = -99
        
        
    # ok libavcodec   52.113. 2    
    enum AVDiscard:
        # we leave some space between them for extensions (drop some keyframes for intra only or drop just some bidir frames)
        AVDISCARD_NONE   = -16 # discard nothing
        AVDISCARD_DEFAULT=   0 # discard useless packets like 0 size packets in avi
        AVDISCARD_NONREF =   8 # discard all non reference
        AVDISCARD_BIDIR  =  16 # discard all bidirectional frames
        AVDISCARD_NONKEY =  32 # discard all frames except keyframes
        AVDISCARD_ALL    =  48 # discard all

    # ok libavcodec   52.113. 2
    enum AVColorPrimaries:
        AVCOL_PRI_BT709       = 1    #< also ITU-R BT1361 / IEC 61966-2-4 / SMPTE RP177 Annex B
        AVCOL_PRI_UNSPECIFIED = 2
        AVCOL_PRI_BT470M      = 4
        AVCOL_PRI_BT470BG     = 5    #< also ITU-R BT601-6 625 / ITU-R BT1358 625 / ITU-R BT1700 625 PAL & SECAM
        AVCOL_PRI_SMPTE170M   = 6    #< also ITU-R BT601-6 525 / ITU-R BT1358 525 / ITU-R BT1700 NTSC
        AVCOL_PRI_SMPTE240M   = 7    #< functionally identical to above
        AVCOL_PRI_FILM        = 8
        AVCOL_PRI_NB          = 9    #< Not part of ABI
      
      
    # ok libavcodec   52.113. 2       
    enum AVColorTransferCharacteristic:
        AVCOL_TRC_BT709       = 1    #< also ITU-R BT1361
        AVCOL_TRC_UNSPECIFIED = 2
        AVCOL_TRC_GAMMA22     = 4    #< also ITU-R BT470M / ITU-R BT1700 625 PAL & SECAM
        AVCOL_TRC_GAMMA28     = 5    #< also ITU-R BT470BG
        AVCOL_TRC_NB          = 6    #< Not part of ABI


    # ok libavcodec   52.113. 2
    enum AVColorSpace:
        AVCOL_SPC_RGB         = 0
        AVCOL_SPC_BT709       = 1    #< also ITU-R BT1361 / IEC 61966-2-4 xvYCC709 / SMPTE RP177 Annex B
        AVCOL_SPC_UNSPECIFIED = 2
        AVCOL_SPC_FCC         = 4
        AVCOL_SPC_BT470BG     = 5    #< also ITU-R BT601-6 625 / ITU-R BT1358 625 / ITU-R BT1700 625 PAL & SECAM / IEC 61966-2-4 xvYCC601
        AVCOL_SPC_SMPTE170M   = 6    #< also ITU-R BT601-6 525 / ITU-R BT1358 525 / ITU-R BT1700 NTSC / functionally identical to above
        AVCOL_SPC_SMPTE240M   = 7
        AVCOL_SPC_NB          = 8    #< Not part of ABI


    # ok libavcodec   52.113. 2
    enum AVColorRange:
        AVCOL_RANGE_UNSPECIFIED = 0
        AVCOL_RANGE_MPEG        = 1  #< the normal 219*2^(n-8) "MPEG" YUV ranges
        AVCOL_RANGE_JPEG        = 2  #< the normal     2^n-1   "JPEG" YUV ranges
        AVCOL_RANGE_NB          = 3  #< Not part of ABI


    # ok libavcodec   52.113. 2
    enum AVChromaLocation:
        AVCHROMA_LOC_UNSPECIFIED = 0
        AVCHROMA_LOC_LEFT        = 1    #< mpeg2/4, h264 default
        AVCHROMA_LOC_CENTER      = 2    #< mpeg1, jpeg, h263
        AVCHROMA_LOC_TOPLEFT     = 3    #< DV
        AVCHROMA_LOC_TOP         = 4
        AVCHROMA_LOC_BOTTOMLEFT  = 5
        AVCHROMA_LOC_BOTTOM      = 6
        AVCHROMA_LOC_NB          = 7    #< Not part of ABI


    # ok libavcodec   52.113. 2
    enum CodecID:
        CODEC_ID_NONE,
    
        # video codecs 
        CODEC_ID_MPEG1VIDEO,
        CODEC_ID_MPEG2VIDEO, #< preferred ID for MPEG-1/2 video decoding
        CODEC_ID_MPEG2VIDEO_XVMC,
        CODEC_ID_H261,
        CODEC_ID_H263,
        CODEC_ID_RV10,
        CODEC_ID_RV20,
        CODEC_ID_MJPEG,
        CODEC_ID_MJPEGB,
        CODEC_ID_LJPEG,
        CODEC_ID_SP5X,
        CODEC_ID_JPEGLS,
        CODEC_ID_MPEG4,
        CODEC_ID_RAWVIDEO,
        CODEC_ID_MSMPEG4V1,
        CODEC_ID_MSMPEG4V2,
        CODEC_ID_MSMPEG4V3,
        CODEC_ID_WMV1,
        CODEC_ID_WMV2,
        CODEC_ID_H263P,
        CODEC_ID_H263I,
        CODEC_ID_FLV1,
        CODEC_ID_SVQ1,
        CODEC_ID_SVQ3,
        CODEC_ID_DVVIDEO,
        CODEC_ID_HUFFYUV,
        CODEC_ID_CYUV,
        CODEC_ID_H264,
        CODEC_ID_INDEO3,
        CODEC_ID_VP3,
        CODEC_ID_THEORA,
        CODEC_ID_ASV1,
        CODEC_ID_ASV2,
        CODEC_ID_FFV1,
        CODEC_ID_4XM,
        CODEC_ID_VCR1,
        CODEC_ID_CLJR,
        CODEC_ID_MDEC,
        CODEC_ID_ROQ,
        CODEC_ID_INTERPLAY_VIDEO,
        CODEC_ID_XAN_WC3,
        CODEC_ID_XAN_WC4,
        CODEC_ID_RPZA,
        CODEC_ID_CINEPAK,
        CODEC_ID_WS_VQA,
        CODEC_ID_MSRLE,
        CODEC_ID_MSVIDEO1,
        CODEC_ID_IDCIN,
        CODEC_ID_8BPS,
        CODEC_ID_SMC,
        CODEC_ID_FLIC,
        CODEC_ID_TRUEMOTION1,
        CODEC_ID_VMDVIDEO,
        CODEC_ID_MSZH,
        CODEC_ID_ZLIB,
        CODEC_ID_QTRLE,
        CODEC_ID_SNOW,
        CODEC_ID_TSCC,
        CODEC_ID_ULTI,
        CODEC_ID_QDRAW,
        CODEC_ID_VIXL,
        CODEC_ID_QPEG,
        CODEC_ID_XVID,        #< LIBAVCODEC_VERSION_MAJOR < 53
        CODEC_ID_PNG,
        CODEC_ID_PPM,
        CODEC_ID_PBM,
        CODEC_ID_PGM,
        CODEC_ID_PGMYUV,
        CODEC_ID_PAM,
        CODEC_ID_FFVHUFF,
        CODEC_ID_RV30,
        CODEC_ID_RV40,
        CODEC_ID_VC1,
        CODEC_ID_WMV3,
        CODEC_ID_LOCO,
        CODEC_ID_WNV1,
        CODEC_ID_AASC,
        CODEC_ID_INDEO2,
        CODEC_ID_FRAPS,
        CODEC_ID_TRUEMOTION2,
        CODEC_ID_BMP,
        CODEC_ID_CSCD,
        CODEC_ID_MMVIDEO,
        CODEC_ID_ZMBV,
        CODEC_ID_AVS,
        CODEC_ID_SMACKVIDEO,
        CODEC_ID_NUV,
        CODEC_ID_KMVC,
        CODEC_ID_FLASHSV,
        CODEC_ID_CAVS,
        CODEC_ID_JPEG2000,
        CODEC_ID_VMNC,
        CODEC_ID_VP5,
        CODEC_ID_VP6,
        CODEC_ID_VP6F,
        CODEC_ID_TARGA,
        CODEC_ID_DSICINVIDEO,
        CODEC_ID_TIERTEXSEQVIDEO,
        CODEC_ID_TIFF,
        CODEC_ID_GIF,
        CODEC_ID_FFH264,
        CODEC_ID_DXA,
        CODEC_ID_DNXHD,
        CODEC_ID_THP,
        CODEC_ID_SGI,
        CODEC_ID_C93,
        CODEC_ID_BETHSOFTVID,
        CODEC_ID_PTX,
        CODEC_ID_TXD,
        CODEC_ID_VP6A,
        CODEC_ID_AMV,
        CODEC_ID_VB,
        CODEC_ID_PCX,
        CODEC_ID_SUNRAST,
        CODEC_ID_INDEO4,
        CODEC_ID_INDEO5,
        CODEC_ID_MIMIC,
        CODEC_ID_RL2,
        CODEC_ID_8SVX_EXP,
        CODEC_ID_8SVX_FIB,
        CODEC_ID_ESCAPE124,
        CODEC_ID_DIRAC,
        CODEC_ID_BFI,
        CODEC_ID_CMV,
        CODEC_ID_MOTIONPIXELS,
        CODEC_ID_TGV,
        CODEC_ID_TGQ,
        CODEC_ID_TQI,
        CODEC_ID_AURA,
        CODEC_ID_AURA2,
        CODEC_ID_V210X,
        CODEC_ID_TMV,
        CODEC_ID_V210,
        CODEC_ID_DPX,
        CODEC_ID_MAD,
        CODEC_ID_FRWU,
        CODEC_ID_FLASHSV2,
        CODEC_ID_CDGRAPHICS,
        CODEC_ID_R210,
        CODEC_ID_ANM,
        CODEC_ID_BINKVIDEO,
        CODEC_ID_IFF_ILBM,
        CODEC_ID_IFF_BYTERUN1,
        CODEC_ID_KGV1,
        CODEC_ID_YOP,
        CODEC_ID_VP8,
        CODEC_ID_PICTOR,
        CODEC_ID_ANSI,
        CODEC_ID_A64_MULTI,
        CODEC_ID_A64_MULTI5,
        CODEC_ID_R10K,
        CODEC_ID_MXPEG,
        CODEC_ID_LAGARITH,
        CODEC_ID_PRORES,
        
        # various PCM "codecs" 
        CODEC_ID_PCM_S16LE= 0x10000,
        CODEC_ID_PCM_S16BE,
        CODEC_ID_PCM_U16LE,
        CODEC_ID_PCM_U16BE,
        CODEC_ID_PCM_S8,
        CODEC_ID_PCM_U8,
        CODEC_ID_PCM_MULAW,
        CODEC_ID_PCM_ALAW,
        CODEC_ID_PCM_S32LE,
        CODEC_ID_PCM_S32BE,
        CODEC_ID_PCM_U32LE,
        CODEC_ID_PCM_U32BE,
        CODEC_ID_PCM_S24LE,
        CODEC_ID_PCM_S24BE,
        CODEC_ID_PCM_U24LE,
        CODEC_ID_PCM_U24BE,
        CODEC_ID_PCM_S24DAUD,
        CODEC_ID_PCM_ZORK,
        CODEC_ID_PCM_S16LE_PLANAR,
        CODEC_ID_PCM_DVD,
        CODEC_ID_PCM_F32BE,
        CODEC_ID_PCM_F32LE,
        CODEC_ID_PCM_F64BE,
        CODEC_ID_PCM_F64LE,
        CODEC_ID_PCM_BLURAY,
        CODEC_ID_PCM_LXF,
       
         # various ADPCM codecs 
        CODEC_ID_ADPCM_IMA_QT= 0x11000,
        CODEC_ID_ADPCM_IMA_WAV,
        CODEC_ID_ADPCM_IMA_DK3,
        CODEC_ID_ADPCM_IMA_DK4,
        CODEC_ID_ADPCM_IMA_WS,
        CODEC_ID_ADPCM_IMA_SMJPEG,
        CODEC_ID_ADPCM_MS,
        CODEC_ID_ADPCM_4XM,
        CODEC_ID_ADPCM_XA,
        CODEC_ID_ADPCM_ADX,
        CODEC_ID_ADPCM_EA,
        CODEC_ID_ADPCM_G726,
        CODEC_ID_ADPCM_CT,
        CODEC_ID_ADPCM_SWF,
        CODEC_ID_ADPCM_YAMAHA,
        CODEC_ID_ADPCM_SBPRO_4,
        CODEC_ID_ADPCM_SBPRO_3,
        CODEC_ID_ADPCM_SBPRO_2,
        CODEC_ID_ADPCM_THP,
        CODEC_ID_ADPCM_IMA_AMV,
        CODEC_ID_ADPCM_EA_R1,
        CODEC_ID_ADPCM_EA_R3,
        CODEC_ID_ADPCM_EA_R2,
        CODEC_ID_ADPCM_IMA_EA_SEAD,
        CODEC_ID_ADPCM_IMA_EA_EACS,
        CODEC_ID_ADPCM_EA_XAS,
        CODEC_ID_ADPCM_EA_MAXIS_XA,
        CODEC_ID_ADPCM_IMA_ISS,
        CODEC_ID_ADPCM_G722,
    
        # AMR 
        CODEC_ID_AMR_NB= 0x12000,
        CODEC_ID_AMR_WB,
     
        # RealAudio codecs
        CODEC_ID_RA_144= 0x13000,
        CODEC_ID_RA_288,
    
        # various DPCM codecs 
        CODEC_ID_ROQ_DPCM= 0x14000,
        CODEC_ID_INTERPLAY_DPCM,
        CODEC_ID_XAN_DPCM,
        CODEC_ID_SOL_DPCM,
    
        # audio codecs 
        CODEC_ID_MP2= 0x15000,
        CODEC_ID_MP3, #< preferred ID for decoding MPEG audio layer 1, 2 or 3
        CODEC_ID_AAC,
        CODEC_ID_AC3,
        CODEC_ID_DTS,
        CODEC_ID_VORBIS,
        CODEC_ID_DVAUDIO,
        CODEC_ID_WMAV1,
        CODEC_ID_WMAV2,
        CODEC_ID_MACE3,
        CODEC_ID_MACE6,
        CODEC_ID_VMDAUDIO,
        CODEC_ID_SONIC,
        CODEC_ID_SONIC_LS,
        CODEC_ID_FLAC,
        CODEC_ID_MP3ADU,
        CODEC_ID_MP3ON4,
        CODEC_ID_SHORTEN,
        CODEC_ID_ALAC,
        CODEC_ID_WESTWOOD_SND1,
        CODEC_ID_GSM, #< as in Berlin toast format
        CODEC_ID_QDM2,
        CODEC_ID_COOK,
        CODEC_ID_TRUESPEECH,
        CODEC_ID_TTA,
        CODEC_ID_SMACKAUDIO,
        CODEC_ID_QCELP,
        CODEC_ID_WAVPACK,
        CODEC_ID_DSICINAUDIO,
        CODEC_ID_IMC,
        CODEC_ID_MUSEPACK7,
        CODEC_ID_MLP,
        CODEC_ID_GSM_MS, # as found in WAV 
        CODEC_ID_ATRAC3,
        CODEC_ID_VOXWARE,
        CODEC_ID_APE,
        CODEC_ID_NELLYMOSER,
        CODEC_ID_MUSEPACK8,
        CODEC_ID_SPEEX,
        CODEC_ID_WMAVOICE,
        CODEC_ID_WMAPRO,
        CODEC_ID_WMALOSSLESS,
        CODEC_ID_ATRAC3P,
        CODEC_ID_EAC3,
        CODEC_ID_SIPR,
        CODEC_ID_MP1,
        CODEC_ID_TWINVQ,
        CODEC_ID_TRUEHD,
        CODEC_ID_MP4ALS,
        CODEC_ID_ATRAC1,
        CODEC_ID_BINKAUDIO_RDFT,
        CODEC_ID_BINKAUDIO_DCT,
        CODEC_ID_AAC_LATM,
        CODEC_ID_QDMC,
        
        # subtitle codecs
        CODEC_ID_DVD_SUBTITLE= 0x17000,
        CODEC_ID_DVB_SUBTITLE,
        CODEC_ID_TEXT,  #< raw UTF-8 text
        CODEC_ID_XSUB,
        CODEC_ID_SSA,
        CODEC_ID_MOV_TEXT,
        CODEC_ID_HDMV_PGS_SUBTITLE,
        CODEC_ID_DVB_TELETEXT,
        CODEC_ID_SRT,
    
        CODEC_ID_TTF= 0x18000,
        CODEC_ID_PROBE= 0x19000,
        CODEC_ID_MPEG2TS= 0x20000
        CODEC_ID_FFMETADATA=0x21000,   #< Dummy codec for streams containing only metadata information.
   
    # ok libavcodec   52.113. 2
    struct AVPanScan:
        int id
        int width
        int height
        int16_t position[3][2]

  
  # ok libavcodec   52.113. 2
    struct AVPacket:
        int64_t pts            #< presentation time stamp in time_base units
        int64_t dts            #< decompression time stamp in time_base units
        char *data
        int   size
        int   stream_index
        int   flags
        int   duration         #< presentation duration in time_base units (0 if not available)
        void  *destruct
        void  *priv
        int64_t pos            #< byte position in Track, -1 if unknown
        #===============================================================================
        # * Time difference in AVStream->time_base units from the pts of this
        # * packet to the point at which the output from the decoder has converged
        # * independent from the availability of previous frames. That is, the
        # * frames are virtually identical no matter if decoding started from
        # * the very first frame or from this keyframe.
        # * Is AV_NOPTS_VALUE if unknown.
        # * This field is not the display duration of the current packet.
        # * This field has no meaning if the packet does not have AV_PKT_FLAG_KEY
        # * set.
        # *
        # * The purpose of this field is to allow seeking in streams that have no
        # * keyframes in the conventional sense. It corresponds to the
        # * recovery point SEI in H.264 and match_time_delta in NUT. It is also
        # * essential for some types of subtitle streams to ensure that all
        # * subtitles are correctly displayed after seeking.
        #===============================================================================
        int64_t convergence_duration
  
    # ok libavcodec   52.113. 2
    struct AVProfile:
        int         profile
        char *      name                    #< short name for the profile


    # ok libavcodec   52.113. 2
    struct AVCodec:
        char *        name
        AVMediaType   type
        CodecID       id
        int           priv_data_size
        int  *        init                   # function pointer
        int  *        encode                 # function pointer
        int  *        close                  # function pointer
        int  *        decode                 # function pointer
        int           capabilities           #< see CODEC_CAP_xxx in 
        AVCodec *     next
        void *        flush        
        AVRational *  supported_framerates   #< array of supported framerates, or NULL 
                                             #  if any, array is terminated by {0,0}
        PixelFormat * pix_fmts               #< array of supported pixel formats, or NULL 
                                             #  if unknown, array is terminanted by -1
        char *        long_name    
        int  *        supported_samplerates  #< array of supported audio samplerates, or NULL if unknown, array is terminated by 0
        AVSampleFormat * sample_fmts         #< array of supported sample formats, or NULL if unknown, array is terminated by -1
        int64_t *     channel_layouts        #< array of support channel layouts, or NULL if unknown. array is terminated by 0
        uint8_t       max_lowres             #< maximum value for lowres supported by the decoder
        void *        priv_class             #< AVClass for the private context
        AVProfile *   profiles               #< array of recognized profiles, or NULL if unknown, array is terminated by {FF_PROFILE_UNKNOWN}
        int  *        init_thread_copy       # function pointer
        int  *        update_thread_context  # function pointer

    # ok libavcodec   52.113. 2  
    struct AVPicture:
        uint8_t *data[4]
        int linesize[4]



    enum AVSubtitleType:
        SUBTITLE_NONE,
        SUBTITLE_BITMAP, #< A bitmap, pict will be set
        SUBTITLE_TEXT,   # Plain text
        SUBTITLE_ASS

    struct AVSubtitleRect:
        int x # top left corner of pict
        int y 
        int w # width
        int h # height
        int nb_colors # number of colors

        AVPicture pict
        AVSubtitleType type

        char *text # 0 terminated plain UTF-8 text
        char *ass

    struct AVSubtitle:
        uint16_t format # 0 = graphics
        uint32_t start_display_time # relative to packet pts, in ms
        uint32_t end_display_time
        unsigned num_rects
        AVSubtitleRect **rects
        int64_t pts    # Same as packet pts, in AV_TIME_BASE




    # ok libavcodec   52.113. 2
    struct AVFrame:
        uint8_t *data[4]                        #< pointer to the picture planes
        int linesize[4]                      #<
        uint8_t *base[4]                     #< pointer to the first allocated byte of the picture. Can be used in get_buffer/release_buffer
        int key_frame                        #< 1 -> keyframe, 0-> not
        int pict_type                        #< Picture type of the frame, see ?_TYPE below
        int64_t pts                          #< presentation timestamp in time_base units (time when frame should be shown to user)
        int coded_picture_number             #< picture number in bitstream order
        int display_picture_number           #< picture number in display order
        int quality                          #< quality (between 1 (good) and FF_LAMBDA_MAX (bad))
        int age                              #< buffer age (1->was last buffer and dint change, 2->..., ...)
        int reference                        #< is this picture used as reference
        int qscale_table                     #< QP table
        int qstride                          #< QP store stride
        uint8_t *mbskip_table                #< mbskip_table[mb]>=1 if MB didn't change, stride= mb_width = (width+15)>>4
        int16_t (*motion_val[2])[2]          #< motion vector table
        uint32_t *mb_type                    #< macroblock type table: mb_type_base + mb_width + 2
        uint8_t motion_subsample_log2        #< log2 of the size of the block which a single vector in motion_val represents: (4->16x16, 3->8x8, 2-> 4x4, 1-> 2x2)
        void *opaque                         #< for some private data of the user
        uint64_t error[4]                    #< unused for decodig
        int type                             #< type of the buffer (to keep track of who has to deallocate data[*]
        int repeat_pict                      #<  When decoding, this signals how much the picture must be delayed: extra_delay = repeat_pict / (2*fps)
        int qscale_type
        int interlaced_frame                 #< The content of the picture is interlaced
        int top_field_first                  #< If the content is interlaced, is top field displayed first
        AVPanScan *pan_scan                  #< Pan scan
        int palette_has_changed              #< Tell user application that palette has changed from previous frame
        int buffer_hints                     #< 
        short *dct_coeff                     #< DCT coefficients
        int8_t *ref_index[2]                 #< motion reference frame index, the order in which these are stored can depend on the codec
        # reordered opaque 64bit (generally an integer or a double precision float
        # PTS but can be anything). 
        # The user sets AVCodecContext.reordered_opaque to represent the input at
        # that time, the decoder reorders values as needed and sets AVFrame.reordered_opaque
        # to exactly one of the values provided by the user through AVCodecContext.reordered_opaque
        # @deprecated in favor of pkt_pts        
        int64_t reordered_opaque
        void *hwaccel_picture_private        #< hardware accelerator private data
        int64_t pkt_pts                      #< reordered pts from the last AVPacket that has been input into the decoder
        int64_t pkt_dts                      #< dts from the last AVPacket that has been input into the decoder
#        AVCodecContext *owner                #< the AVCodecContext which ff_thread_get_buffer() was last called on
        void *thread_opaque                  #< used by multithreading to store frame-specific info


    # ok libavcodec   52.113. 2
    struct AVCodecContext:
        void *      av_class
        int         bit_rate
        int         bit_rate_tolerance
        int         flags
        int         sub_id
        int         me_method
        uint8_t *   extradata
        int         extradata_size
        AVRational  time_base
        int         width
        int         height
        int         gop_size
        PixelFormat pix_fmt
        int         rate_emu
        void *      draw_horiz_band
        int         sample_rate
        int         channels
        int         sample_fmt
        int         frame_size
        int         frame_number
        int         real_pict_num          #< only for LIBAVCODEC_VERSION_MAJOR < 53
        int         delay
        float       qcompress
        float       qblur
        int         qmin
        int         qmax
        int         max_qdiff
        int         max_b_frames
        float       b_quant_factor
        int         rc_strategy            #< will be removed in later libav versions
        int         b_frame_strategy
#        int         hurry_up               #< hurry up amount: decoding: Set by user. 1-> Skip B-frames, 2-> Skip IDCT/dequant too, 5-> Skip everything except header
        AVCodec *   codec
        void *      priv_data
        int         rtp_payload_size
        void *      rtp_callback
        # statistics, used for 2-pass encoding
        int         mv_bits
        int         header_bits
        int         i_tex_bits
        int         p_tex_bits
        int         i_count
        int         p_count
        int         skip_count
        int         misc_bits
        int         frame_bits
        void *      opaque
        char        codec_name[32]
        int         codec_type             #< see AVMEDIA_TYPE_xxx in avcodec.h
        CodecID     codec_id               #< see CODEC_ID_xxx in avcodec.h
        unsigned int codec_tag
        int         workaround_bugs
        int         luma_elim_threshold
        int         chroma_elim_threshold
        int         strict_std_compliance  #< see FF_COMPLIANCE_xxx in avcodec.h
        float       b_quant_offset
        int         error_recognition      #< see FF_ER_xxx in avcodec.h
        int  *      get_buffer
        void *      release_buffer
        int         has_b_frames           #< Size of the frame reordering buffer in the decoder: e.g. For MPEG-2 it is 1 IPB or 0 low delay IP 
        int         block_align
        int         parse_only             #< decoding only: If true, only parsing is done
                                           #(function avcodec_parse_frame()). The frame
                                           # data is returned. Only MPEG codecs support this now.
        int         mpeg_quant
        char *      stats_out
        char *      stats_in
        float       rc_qsquish
        float       rc_qmod_amp
        int         rc_qmod_freq
        void *      rc_override
        int         rc_override_count
        char *      rc_eq
        int         rc_max_rate
        int         rc_min_rate
        int         rc_buffer_size
        float       rc_buffer_aggressivity
        float       i_quant_factor
        float       i_quant_offset
        float       rc_initial_cplx
        int         dct_algo                #< only coding: DCT algorithm see FF_DCT_xxx in avcodec.h
        float       lumi_masking
        float       temporal_cplx_masking
        float       spatial_cplx_masking
        float       p_masking
        float       dark_masking
        int         idct_algo               #< IDCT algorithm: see  FF_IDCT_xxx in avcodec.h
        int         slice_count
        int *       slice_offset
        int         error_concealment       #< only decoding: see FF_EC_xxx in avcodec.h
        unsigned    dsp_mask           #< dsp_mask could be add used to disable unwanted CPU features (i.e. MMX, SSE. ...)
                                        # see FF_MM_xxx in avcodec.h
        int         bits_per_coded_sample
        int         prediction_method       #< only encoding
        AVRational  sample_aspect_ratio
        AVFrame *   coded_frame       #< the picture in the bitstream
        int         debug                   #< encoding/decoding: see FF_DEBUG_xxx in avcodec.h
        int         debug_mv
        uint64_t    error[4]
        int         mb_qmin
        int         mb_qmax
        int         me_cmp
        int         me_sub_cmp
        int         mb_cmp
        int         ildct_cmp
        int         dia_size
        int         last_predictor_count
        int         pre_me
        int         me_pre_cmp
        int         pre_dia_size
        int         me_subpel_quality
        PixelFormat * get_format
        int         dtg_active_format        #< decoding: DTG active format information 
                                             # (additional aspect ratio  information 
                                             # only used in DVB MPEG-2 transport streams)
                                             # 0  if not set. See FF_DTG_AFD_xxx in avcodec.h
        int         me_range
        int         intra_quant_bias
        int         inter_quant_bias
        int         color_table_id
        int         internal_buffer_count
        void *      internal_buffer
        int         global_quality
        int         coder_type
        int         context_model
        int         slice_flags                #< see SLICE_FLAG_xxx in avcodec.h
        int         xvmc_acceleration
        int         mb_decision
        uint16_t *  intra_matrix
        uint16_t *  inter_matrix
        unsigned int stream_codec_tag          #< decoding: fourcc from the AVI stream header (LSB first, so "ABCD" -> ('D'<<24) + ('C'<<16) + ('B'<<8) + 'A')
        int         scenechange_threshold      #< encoding
        int         lmin
        int         lmax
        void *      palctrl             #< LIBAVCODEC_VERSION_MAJOR < 54
        int         noise_reduction
        int  *      reget_buffer
        int         rc_initial_buffer_occupancy
        int         inter_threshold
        int         flags2                     #< see CODEC_FLAG2_xxx in avcodec.h
        int         error_rate                 #< EV
        int         antialias_algo             #< DA MP3 antialias algorithm, see FF_AA_* below
        int         quantizer_noise_shaping    #< E
        int         thread_count               #< E/D set the number of threads
        int  *      execute        
        void *      thread_opaque
        int         me_threshold
        int         mb_threshold
        int         intra_dc_precision
        int         nsse_weight
        int         skip_top
        int         skip_bottom
        int         profile                    #< profile, see FF_PROFILE_xxx in avcodec.h
        int         level                      #< level, see FF_LEVEL_xxx in avcodec.h
        int         lowres                     #< decoding: low resolution decoding,
                                               # 1-> 1/2 size, 2->1/4 size
        int         coded_width
        int         coded_height
        int         frame_skip_threshold
        int         frame_skip_factor
        int         frame_skip_exp
        int         frame_skip_cmp
        float       border_masking
        int         mb_lmin
        int         mb_lmax
        int         me_penalty_compensation
        AVDiscard   skip_loop_filter        #< VD
        AVDiscard   skip_idct               #< VD
        AVDiscard   skip_frame              #< VD
        int         bidir_refine            #< VE 
        int         brd_scale               #< VE 
        float       crf                     #< VE
        int         cqp                     #< VE
        int         keyint_min              #< VE: minimum GOP size
        int         refs                    #< VE: number of reference frames
        int         chromaoffset            #< VE: chroma qp offset from luma
        int         bframebias              #< VE: Influences how often B-frames are used
        int         trellis                 #< VE: trellis RD quantization
        float       complexityblur          #< VE: Reduce fluctuations in qp (before curve compression)
        int         deblockalpha            #< VE: in-loop deblocking filter alphac0 parameter (range: -6..6)
        int         deblockbeta             #< VE: in-loop deblocking filter beta parameter (range: -6..6)
        int         partitions              #< VE: macroblock subpartition sizes to consider 
                                            #      - p8x8, p4x4, b8x8, i8x8, i4x4, see X264_PART_xxx in avcodec.h
        int         directpred              #< VE: direct MV prediction mode - 0 (none), 1 (spatial), 2 (temporal), 3 (auto)
        int         cutoff                  #< AE: Audio cutoff bandwidth (0 means "automatic")
        int         scenechange_factor      #< VE: Multiplied by qscale for each frame and added to scene_change_score
        int         mv0_threshold           #< VE: Note: Value depends upon the compare function used for fullpel ME 
        int         b_sensitivity           #< VE: Adjusts sensitivity of b_frame_strategy 1 
        int         compression_level       #< VE
        int         use_lpc                 #< AE
        int         lpc_coeff_precision     #< AE
        int         min_prediction_order    #< AE
        int         max_prediction_order    #< AE
        int         prediction_order_method 
        int         min_partition_order
        int         max_partition_order
        int64_t     timecode_frame_start    #< VE: GOP timecode frame start number, in non drop frame format 
        int         request_channels        #< Decoder should decode to this many channels if it can (0 for default)
                                            # LIBAVCODEC_VERSION_MAJOR < 53
        float       drc_scale               #< AD: Percentage of dynamic range compression to be applied by the decoder
                                            # The default value is 1.0, corresponding to full compression.
        int64_t     reordered_opaque        #<  @deprecated in favor of pkt_pts, opaque 64bit number (generally a PTS) 
                                            # that will be reordered and output in 
                                            # AVFrame.reordered_opaque
        int         bits_per_raw_sample     #< VE/VD: Bits per sample/pixel of internal libavcodec pixel/sample format
        int64_t     channel_layout          #< AE/AD: Audio channel layout
        int64_t     request_channel_layout  #< AD: Request decoder to use this channel layout if it can (0 for default)
        float       rc_max_available_vbv_use #< Ratecontrol attempt to use, at maximum, <value> of what can be used without an underflow        
        float       rc_min_vbv_overflow_use #< Ratecontrol attempt to use, at least, <value> times the amount needed to prevent a vbv overflow
        void *      hwaccel                 #< Hardware accelerator in use
        int         ticks_per_frame         #< VD/VE: Set to time_base ticks per frame. Default 1, e.g., H.264/MPEG-2 set it to 2.
        void *      hwaccel_context         #< Hardware accelerator context
        AVColorPrimaries color_primaries    #< VE/VD: Chromaticity coordinates of the source primaries
        AVColorTransferCharacteristic color_trc #< VE/VD: Color Transfer Characteristic 
        AVColorSpace colorspace             #< VE/VD: YUV colorspace type
        AVColorRange color_range            #< VE/VD:  MPEG vs JPEG YUV range
        AVChromaLocation chroma_sample_location #< VE/VD: This defines the location of chroma samples
        int  *      execute2    
        int         weighted_p_pred         #< VE: explicit P-frame weighted prediction analysis method
        int         aq_mode
        float       aq_strength
        float       psy_rd                  #< VE
        float       psy_trellis             #< VE
        int         rc_lookahead             #< VE
        float       crf_max             #< VE
        int         log_level_offset
        int         lpc_type
        int         lpc_passes
        int         slices                        #< Number of slices
        uint8_t *   subtitle_header
        int         subtitle_header_size
        AVPacket *  pkt                     #< VD: Current packet as passed into the decoder
        int         is_copy                 #< VE/VD: Whether this is a copy of the context which had init() called on it, This is used by multithreading - shared tables and picture pointers should be freed from the original context only.
        int         thread_type             #< VES/VDS: Which multithreading methods to use: frame 1, slice 2
        int         active_thread_type      #< VEG/VDG: Which multithreading methods are in use by the codec
        int         thread_safe_callbacks   #< VES/VDS:  Set by the client if its custom get_buffer() callback can be called
        uint64_t    vbv_delay               #< VEG: VBV delay coded in the last frame (in periods of a 27 MHz clock)
    
    
    # AVCodecParserContext.flags
    enum:
        PARSER_FLAG_COMPLETE_FRAMES          = 0x0001
        PARSER_FLAG_ONCE                     = 0x0002
        PARSER_FLAG_FETCHED_OFFSET           = 0x0004        #< Set if the parser has a valid file offset

    # for AVCodecParserContext array lengths
    enum:        
        AV_PARSER_PTS_NB = 4        
     

    struct AVCodecParser:
        pass
     
     
    struct AVCodecParserContext:
        void *priv_data
        AVCodecParser *parser
        int64_t frame_offset                #< offset of the current frame 
        int64_t cur_offset                      #< current offset (incremented by each av_parser_parse()) 
        int64_t next_frame_offset               #< offset of the next frame 
        # video info 
        int pict_type #< XXX: Put it back in AVCodecContext. 
        #     * This field is used for proper frame duration computation in lavf.
        #     * It signals, how much longer the frame duration of the current frame
        #     * is compared to normal frame duration.
        #     * frame_duration = (1 + repeat_pict) * time_base
        #     * It is used by codecs like H.264 to display telecined material.
        int repeat_pict #< XXX: Put it back in AVCodecContext. 
        int64_t pts     #< pts of the current frame 
        int64_t dts     #< dts of the current frame 

        # private data 
        int64_t last_pts
        int64_t last_dts
        int fetch_timestamp

        int cur_frame_start_index
        int64_t cur_frame_offset[AV_PARSER_PTS_NB]
        int64_t cur_frame_pts[AV_PARSER_PTS_NB]
        int64_t cur_frame_dts[AV_PARSER_PTS_NB]
        int flags
        int64_t offset      #< byte offset from starting packet start
        int64_t cur_frame_end[AV_PARSER_PTS_NB]
        #     * Set by parser to 1 for key frames and 0 for non-key frames.
        #     * It is initialized to -1, so if the parser doesn't set this flag,
        #     * old-style fallback using FF_I_TYPE picture type as key frames
        #     * will be used.
        int key_frame
        #     * Time difference in stream time base units from the pts of this
        #     * packet to the point at which the output from the decoder has converged
        #     * independent from the availability of previous frames. That is, the
        #     * frames are virtually identical no matter if decoding started from
        #     * the very first frame or from this keyframe.
        #     * Is AV_NOPTS_VALUE if unknown.
        #     * This field is not the display duration of the current frame.
        #     * This field has no meaning if the packet does not have AV_PKT_FLAG_KEY
        #     * set.
        #     *
        #     * The purpose of this field is to allow seeking in streams that have no
        #     * keyframes in the conventional sense. It corresponds to the
        #     * recovery point SEI in H.264 and match_time_delta in NUT. It is also
        #     * essential for some types of subtitle streams to ensure that all
        #     * subtitles are correctly displayed after seeking.
        int64_t convergence_duration
        # Timestamp generation support:
        #     * Synchronization point for start of timestamp generation.
        #     *
        #     * Set to >0 for sync point, 0 for no sync point and <0 for undefined
        #     * (default).
        #     *
        #     * For example, this corresponds to presence of H.264 buffering period
        #     * SEI message.
        int dts_sync_point
        #     * Offset of the current timestamp against last timestamp sync point in
        #     * units of AVCodecContext.time_base.
        #     * Set to INT_MIN when dts_sync_point unused. Otherwise, it must
        #     * contain a valid timestamp offset.
        #     * Note that the timestamp of sync point has usually a nonzero
        #     * dts_ref_dts_delta, which refers to the previous sync point. Offset of
        #     * the next frame after timestamp sync point will be usually 1.
        #     * For example, this corresponds to H.264 cpb_removal_delay.
        int dts_ref_dts_delta
        #     * Presentation delay of current frame in units of AVCodecContext.time_base.
        #     * Set to INT_MIN when dts_sync_point unused. Otherwise, it must
        #     * contain valid non-negative timestamp delta (presentation time of a frame
        #     * must not lie in the past).
        #     * This delay represents the difference between decoding and presentation
        #     * time of the frame.
        #     * For example, this corresponds to H.264 dpb_output_delay.
        int pts_dts_delta
        int64_t cur_frame_pos[AV_PARSER_PTS_NB]            #< Position of the packet in file. Analogous to cur_frame_pts/dts
        int64_t pos                                        #< * Byte position of currently parsed frame in stream.
        int64_t last_pos                                   #< * Previous frame byte position.
        

    AVCodec *avcodec_find_encoder(CodecID id)
    #AVCodec *avcodec_find_encoder_by_name(const char *name)
    AVCodec *avcodec_find_decoder(CodecID id)
    #AVCodec *avcodec_find_decoder_by_name(const char *name)
    
    int avcodec_open(AVCodecContext *avctx, AVCodec *codec)

    int avcodec_close(AVCodecContext *avctx)

    # deprecated ... use instead avcodec_decode_video2
    #int avcodec_decode_video(AVCodecContext *avctx, AVFrame *picture,
    #                     int *got_picture_ptr,
    #                     char *buf, int buf_size)
    int avcodec_decode_video2(AVCodecContext *avctx, AVFrame *picture,
                         int *got_picture_ptr,
                         AVPacket *avpkt)
    
    # TODO                     
    # deprecated ... use instead avcodec_decode_audio3
    #int avcodec_decode_audio2(AVCodecContext *avctx, #AVFrame *picture,
    #                     int16_t * samples, int * frames,
    #                     void *buf, int buf_size)
    int avcodec_decode_audio3(AVCodecContext *avctx, int16_t *samples,
                         int *frame_size_ptr,
                         AVPacket *avpkt)
    int avcodec_encode_audio(AVCodecContext *avctx, uint8_t *buf, int buf_size,
                         int16_t *samples)
    int avcodec_encode_video(AVCodecContext *avctx, uint8_t *buf, int buf_size,
                         AVFrame *pict)
#    int avcodec_encode_subtitle(AVCodecContext *avctx, uint8_t *buf, int buf_size,
#                            const AVSubtitle *sub)
    int avpicture_fill(AVPicture *picture, uint8_t *ptr,
                       PixelFormat pix_fmt, int width, int height)
    int avpicture_layout(AVPicture* src, PixelFormat pix_fmt, 
                         int width, int height, unsigned char *dest, int dest_size)

    int avpicture_get_size(PixelFormat pix_fmt, int width, int height)
    void avcodec_get_chroma_sub_sample(PixelFormat pix_fmt, int *h_shift, int *v_shift)
    char *avcodec_get_pix_fmt_name(PixelFormat pix_fmt)
    void avcodec_set_dimensions(AVCodecContext *s, int width, int height)

    AVFrame *avcodec_alloc_frame()
    
    void avcodec_flush_buffers(AVCodecContext *avctx)
    # Return a single letter to describe the given picture type pict_type.
    char av_get_pict_type_char(int pict_type)

    # * Parse a packet.
    # *
    # * @param s             parser context.
    # * @param avctx         codec context.
    # * @param poutbuf       set to pointer to parsed buffer or NULL if not yet finished.
    # * @param poutbuf_size  set to size of parsed buffer or zero if not yet finished.
    # * @param buf           input buffer.
    # * @param buf_size      input length, to signal EOF, this should be 0 (so that the last frame can be output).
    # * @param pts           input presentation timestamp.
    # * @param dts           input decoding timestamp.
    # * @param pos           input byte position in stream.
    # * @return the number of bytes of the input bitstream used.
    # *
    # * Example:
    # * @code
    # *   while(in_len){
    # *       len = av_parser_parse2(myparser, AVCodecContext, &data, &size,
    # *                                        in_data, in_len,
    # *                                        pts, dts, pos);
    # *       in_data += len;
    # *       in_len  -= len;
    # *
    # *       if(size)
    # *          decode_frame(data, size);
    # *   }
    # * @endcode
    int av_parser_parse2(AVCodecParserContext *s,
                     AVCodecContext *avctx,
                     uint8_t **poutbuf, int *poutbuf_size,
                     uint8_t *buf, int buf_size,
                     int64_t pts, int64_t dts,
                     int64_t pos)
    int av_parser_change(AVCodecParserContext *s,
                     AVCodecContext *avctx,
                     uint8_t **poutbuf, int *poutbuf_size,
                     uint8_t *buf, int buf_size, int keyframe)
    void av_parser_close(AVCodecParserContext *s)


    # * Free a packet.
    # * @param pkt packet to free
    void av_free_packet(AVPacket *pkt)

