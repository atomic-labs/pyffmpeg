# -*- coding: utf-8 -*-

"""
##################################################################################
# PyFFmpeg v2.2 alpha 1
#
# Copyright (C) 2011 Martin Haller <martin.haller@computer.org>
# Copyright (C) 2011 Bertrand Nouvel <bertrand@lm3labs.com>
# Copyright (C) 2008-2010 Bertrand Nouvel <nouvel@nii.ac.jp>
#   Japanese French Laboratory for Informatics -  CNRS
#
##################################################################################
#  This file is distibuted under LGPL-3.0
#  See COPYING file attached.
##################################################################################
#
#    TODO:
#       * check motion vector related functions
#       * why seek_before mandatory
#       * Add support for video encoding
#       * add multithread support
#       * Fix first frame bug... 
#
#    Abilities
#     * Frame seeking (TO BE CHECKED again and again)
#
#    Changed compared with PyFFmpeg version 1.0:
#     * Clean up destructors
#     * Added compatibility with NumPy and PIL
#     * Added copyless mode for ordered streams/tracks ( when buffers are disabled)
#     * Added audio support
#     * MultiTrack support (possibility to pass paramer)
#     * Added support for streamed video
#     * Updated ID for compatibility with transparency
#     * Updated to latest avcodec primitives
#
##################################################################################
# Based on Pyffmpeg 0.2 by
# Copyright (C) 2006-2007 James Evans <jaevans@users.sf.net>
# Authorization to change from GPL2.0 to LGPL 3.0 provided by original author for 
# this new version
##################################################################################
"""

##################################################################################
# Settings
##################################################################################
AVCODEC_MAX_AUDIO_FRAME_SIZE=192000
AVPROBE_PADDING_SIZE=32
OUTPUTMODE_NUMPY=0
OUTPUTMODE_PIL=1


##################################################################################
#  Declaration and imports
##################################################################################
import sys
import traceback
from avutil cimport *
from avcodec cimport *
from avformat cimport *
from swscale cimport *


##################################################################################
cdef extern from "string.h":
    memcpy(void * dst, void * src, unsigned long sz)
    memset(void * dst, unsigned char c, unsigned long sz)


##################################################################################
cdef extern from "Python.h":
    ctypedef int size_t
    object PyBuffer_FromMemory( void *ptr, int size)
    object PyBuffer_FromReadWriteMemory( void *ptr, int size)
    object PyString_FromStringAndSize(char *s, int len)
    void* PyMem_Malloc( size_t n)
    void PyMem_Free( void *p)

##################################################################################
# Used for debugging
##################################################################################

#class DLock:
#    def __init__(self):
#        self.l=threading.Lock()
#    def acquire(self,*args,**kwargs):
#        sys.stderr.write("MTX:"+str((self, "A", args, kwargs))+"\n")
#        try:
#            raise Exception
#        except:
#            if (hasattr(sys,"last_traceback")):
#                traceback.print_tb(sys.last_traceback)
#            else:
#                traceback.print_tb(sys.exc_traceback)
#        sys.stderr.flush()
#        sys.stdout.flush()
#        #return self.l.acquire(*args,**kwargs)
#        return True
#    def release(self):
#        sys.stderr.write("MTX:"+str((self, "R"))+"\n")
#        try:
#            raise Exception
#        except:
#            if (hasattr(sys,"last_traceback")):
#                traceback.print_tb(sys.last_traceback)
#            else:
#                traceback.print_tb(sys.exc_traceback)
#        sys.stderr.flush()
#        sys.stdout.flush()
#        #return self.l.release()

##################################################################################
cdef extern from "Python.h":
    ctypedef unsigned long size_t
    object PyBuffer_FromMemory( void *ptr, int size)
    object PyBuffer_FromReadWriteMemory( void *ptr, int size)
    object PyString_FromStringAndSize(char *s, int len)
    void* PyMem_Malloc( size_t n)
    void PyMem_Free( void *p)


def rwbuffer_at(pos,len):
    cdef unsigned long ptr=int(pos)
    return PyBuffer_FromReadWriteMemory(<void *>ptr,len)


##################################################################################
# General includes
##################################################################################
try:
    import numpy
    from pyffmpeg_numpybindings import *
except:
    numpy=None

try:
    import PIL
    from PIL import Image
except:
    Image=None


##################################################################################
# Utility elements
##################################################################################

AVFMT_NOFILE = 1

cdef av_read_frame_flush(AVFormatContext *s):
    cdef AVStream *st
    cdef int i
    #flush_packet_queue(s);
    if (s.cur_st) :
        #if (s.cur_st.parser):
        #    av_free_packet(&s.cur_st.cur_pkt)
        s.cur_st = NULL

    #s.cur_st.cur_ptr = NULL;
    #s.cur_st.cur_len = 0;

    for i in range(s.nb_streams) :
        st = s.streams[i]

        if (st.parser) :
            av_parser_close(st.parser)
            st.parser = NULL
            st.last_IP_pts = AV_NOPTS_VALUE
            st.cur_dts = 0

# originally defined in mpegvideo.h
def IS_INTRA4x4(mb_type):
    return ((mb_type & MB_TYPE_INTRA4x4)>0)*1
def IS_INTRA16x16(mb_type):
    return ((mb_type & MB_TYPE_INTRA16x16)>0)*1
def IS_INTRA4x4(a):
    return (((a)&MB_TYPE_INTRA4x4)>0)*1
def IS_INTRA16x16(a):
    return (((a)&MB_TYPE_INTRA16x16)>0)*1
def IS_PCM(a):        
    return (((a)&MB_TYPE_INTRA_PCM)>0)*1
def IS_INTRA(a):      
    return (((a)&7)>0)*1
def IS_INTER(a):      
    return (((a)&(MB_TYPE_16x16|MB_TYPE_16x8|MB_TYPE_8x16|MB_TYPE_8x8))>0)*1
def IS_SKIP(a):       
    return (((a)&MB_TYPE_SKIP)>0)*1
def IS_INTRA_PCM(a):  
    return (((a)&MB_TYPE_INTRA_PCM)>0)*1
def IS_INTERLACED(a): 
    return (((a)&MB_TYPE_INTERLACED)>0)*1
def IS_DIRECT(a):     
    return (((a)&MB_TYPE_DIRECT2)>0)*1
def IS_GMC(a):        
    return (((a)&MB_TYPE_GMC)>0)*1
def IS_16x16(a):      
    return (((a)&MB_TYPE_16x16)>0)*1
def IS_16x8(a):       
    return (((a)&MB_TYPE_16x8)>0)*1
def IS_8x16(a):       
    return (((a)&MB_TYPE_8x16)>0)*1
def IS_8x8(a):        
    return (((a)&MB_TYPE_8x8)>0)*1
def IS_SUB_8x8(a):    
    return (((a)&MB_TYPE_16x16)>0)*1 #note reused
def IS_SUB_8x4(a):    
    return (((a)&MB_TYPE_16x8)>0)*1  #note reused
def IS_SUB_4x8(a):    
    return (((a)&MB_TYPE_8x16)>0)*1  #note reused
def IS_SUB_4x4(a):    
    return (((a)&MB_TYPE_8x8)>0)*1   #note reused
def IS_DIR(a, part, whichlist):
    return (((a) & (MB_TYPE_P0L0<<((part)+2*(whichlist))))>0)*1
def USES_LIST(a, whichlist):
    return (((a) & ((MB_TYPE_P0L0|MB_TYPE_P1L0)<<(2*(whichlist))))>0)*1 #< does this mb use listX, note does not work if subMBs


##################################################################################
## AudioQueue Object  (This may later be exported with another object)
##################################################################################
cdef DEBUG(s):
    sys.stderr.write("DEBUG: %s\n"%(s,))
    sys.stderr.flush()

## contains pairs of timestamp, array
try:
    from audioqueue import AudioQueue, Queue_Empty, Queue_Full
except:
    pass


##################################################################################
# Initialization
##################################################################################

cdef __registered
__registered = 0
if not __registered:
    __registered = 1
    av_register_all()


##################################################################################
# Some default settings
##################################################################################
TS_AUDIOVIDEO={'video1':(AVMEDIA_TYPE_VIDEO, -1,  {}), 'audio1':(AVMEDIA_TYPE_AUDIO, -1, {})}
TS_AUDIO={ 'audio1':(AVMEDIA_TYPE_AUDIO, -1, {})}
TS_VIDEO={ 'video1':(AVMEDIA_TYPE_VIDEO, -1, {})}
TS_VIDEO_PIL={ 'video1':(AVMEDIA_TYPE_VIDEO, -1, {'outputmode':OUTPUTMODE_PIL})}


###############################################################################
## The Abstract Reader Class
###############################################################################
cdef class AFFMpegReader:
    """ Abstract version of FFMpegReader"""
    ### File
    cdef object filename
    ### used when streaming
    cdef AVIOContext *io_context
    ### Tracks contained in the file
    cdef object tracks
    cdef void * ctracks
    ### current timing
    cdef float opts ## orginal pts recoded as a float
    cdef unsigned long long int pts
    cdef unsigned long long int dts
    cdef unsigned long long int errjmppts # when trying to skip over buggy area
    cdef unsigned long int frameno
    cdef float fps # real frame per seconds (not declared one)
    cdef float tps # ticks per seconds

    cdef AVPacket * packet
    cdef AVPacket * prepacket
    cdef AVPacket packetbufa
    cdef AVPacket packetbufb
    cdef int altpacket
    #
    cdef bint observers_enabled

    cdef AVFormatContext *FormatCtx
 #   self.prepacket=<AVPacket *>None
#   self.packet=&self.packetbufa

    def __cinit__(self):
        pass

    def dump(self):
        pass

    def open(self,char *filename, track_selector={'video1':(AVMEDIA_TYPE_VIDEO, -1), 'audio1':(AVMEDIA_TYPE_AUDIO, -1)}):
        pass

    def close(self):
        pass

    cdef read_packet(self):
        print "FATAL Error This function is abstract and should never be called, it is likely that you compiled pyffmpeg with a too old version of pyffmpeg !!!"
        print "Try running 'easy_install -U cython' and rerun the pyffmpeg2 install"
        assert(False)

    def process_current_packet(self):
        pass

    def __prefetch_packet(self):
        pass

    def read_until_next_frame(self):
        pass

cdef class Track:
    """
     A track is used for memorizing all the aspect related to
     Video, or an Audio Track.

     Practically a Track is managing the decoder context for itself.
    """
    cdef AFFMpegReader vr
    cdef int no
    ## cdef AVFormatContext *FormatCtx
    cdef AVCodecContext *CodecCtx
    cdef AVCodec *Codec
    cdef AVFrame *frame
    cdef AVStream *stream
    cdef long start_time
    cdef object packet_queue
    cdef frame_queue
    cdef unsigned long long int pts
    cdef unsigned long long int last_pts
    cdef unsigned long long int last_dts
    cdef object observer
    cdef int support_truncated
    cdef int do_check_start
    cdef int do_check_end
    cdef int reopen_codec_on_buffer_reset

    cdef __new__(Track self):
        self.vr=None
        self.observer=None
        self.support_truncated=1
        self.reopen_codec_on_buffer_reset=1

    def get_no(self):
        """Returns the number of the tracks."""
        return self.no

    def __len__(self):
        """Returns the number of data frames on this track."""
        return self.stream.nb_frames

    def duration(self):
        """Return the duration of one track in PTS"""
        if (self.stream.duration==0x8000000000000000):
            raise KeyError
        return self.stream.duration

    def _set_duration(self,x):
        """Allows to set the duration to correct inconsistent information"""
        self.stream.duration=x

    def duration_time(self):
        """ returns the duration of one track in seconds."""
        return float(self.duration())/ (<float>AV_TIME_BASE)

    cdef init0(Track self,  AFFMpegReader vr,int no, AVCodecContext *CodecCtx):
        """ This is a private constructor """
        self.vr=vr
        self.CodecCtx=CodecCtx
        self.no=no
        self.stream = self.vr.FormatCtx.streams[self.no]
        self.frame_queue=[]
        self.Codec = avcodec_find_decoder(self.CodecCtx.codec_id)
        self.frame = avcodec_alloc_frame()
        self.start_time=self.stream.start_time
        self.do_check_start=0
        self.do_check_end=0


    def init(self,observer=None, support_truncated=0,   **args):
        """ This is a private constructor

            It supports also the following parameted from ffmpeg
            skip_frame
            skip_idct
            skip_loop_filter
            dct_algo
            idct_algo

            To set all value for keyframes_only
            just set up hurry_mode to any value.
        """
        self.observer=None
        self.support_truncated=support_truncated
        for k in args.keys():
            if k not in [ "skip_frame", "skip_loop_filter", "skip_idct", "hurry_mode", "dct_algo", "idct_algo", "check_start" ,"check_end"]:
                sys.stderr.write("warning unsupported arguments in stream initialization :"+k+"\n")
        if self.Codec == NULL:
            raise IOError("Unable to get decoder")
        if (self.Codec.capabilities & CODEC_CAP_TRUNCATED) and (self.support_truncated!=0):
            self.CodecCtx.flags = self.CodecCtx.flags | CODEC_FLAG_TRUNCATED
        avcodec_open(self.CodecCtx, self.Codec)
        if args.has_key("hurry_mode"):
            # discard all frames except keyframes
            self.CodecCtx.skip_loop_filter = AVDISCARD_NONKEY
            self.CodecCtx.skip_frame = AVDISCARD_NONKEY
            self.CodecCtx.skip_idct = AVDISCARD_NONKEY
        if args.has_key("skip_frame"):
            self.CodecCtx.skip_frame=args["skip_frame"]
        if args.has_key("skip_idct"):
            self.CodecCtx.skip_idct=args["skip_idct"]
        if args.has_key("skip_loop_filter"):
            self.CodecCtx.skip_loop_filter=args["skip_loop_filter"]
        if args.has_key("dct_algo"):
            self.CodecCtx.dct_algo=args["dct_algo"]
        if args.has_key("idct_algo"):
            self.CodecCtx.idct_algo=args["idct_algo"]
        if not args.has_key("check_start"): 
            self.do_check_start=1
        else:
            self.do_check_start=args["check_start"]
        if (args.has_key("check_end") and args["check_end"]):
            self.do_check_end=0


    def check_start(self):
        """ It seems that many file have incorrect initial time information.
            The best way to avoid offset in shifting is thus to check what
            is the time of the beginning of the track.
        """
        if (self.do_check_start):
            try:
                self.seek_to_pts(0)
                self.vr.read_until_next_frame()
                sys.stderr.write("start time checked : pts = %d , declared was : %d\n"%(self.pts,self.start_time))
                self.start_time=self.pts
                self.seek_to_pts(0)
                self.do_check_start=0
            except Exception,e:
                #DEBUG("check start FAILED " + str(e))
                pass
        else:
            pass


    def check_end(self):
        """ It seems that many file have incorrect initial time information.
            The best way to avoid offset in shifting is thus to check what
            is the time of the beginning of the track.
        """
        if (self.do_check_end):
            try:
                self.vr.packetbufa.dts=self.vr.packetbufa.pts=self.vr.packetbufb.dts=self.vr.packetbufb.pts=0
                self.seek_to_pts(0x00FFFFFFFFFFFFF)
                self.vr.read_packet()
                try:
                    dx=self.duration()
                except:
                    dx=-1
                newend=max(self.vr.packetbufa.dts,self.vr.packetbufa.pts,self.vr.packetbufb.dts)
                sys.stderr.write("end time checked : pts = %d, declared was : %d\n"%(newend,dx))
                assert((newend-self.start_time)>=0)
                self._set_duration((newend-self.start_time))
                self.vr.reset_buffers()
                self.seek_to_pts(0)
                self.do_check_end=0
            except Exception,e:
                DEBUG("check end FAILED " + str(e))
                pass
        else:
            #DEBUG("no check end " )
            pass

    def set_observer(self, observer=None):
        """ An observer is a callback function that is called when a new
            frame of data arrives.

            Using this function you may setup the function to be called when
            a frame of data is decoded on that track.
        """
        self.observer=observer

    def _reopencodec(self):
        """
          This is used to reset the codec context.
          Very often, this is the safest way to get everything clean
          when seeking.
        """
        if (self.CodecCtx!=NULL):
            avcodec_close(self.CodecCtx)
        self.CodecCtx=NULL
        self.CodecCtx = self.vr.FormatCtx.streams[self.no].codec
        self.Codec = avcodec_find_decoder(self.CodecCtx.codec_id)
        if self.Codec == NULL:
            raise IOError("Unable to get decoder")
        if (self.Codec.capabilities & CODEC_CAP_TRUNCATED) and (self.support_truncated!=0):
            self.CodecCtx.flags = self.CodecCtx.flags | CODEC_FLAG_TRUNCATED
        ret = avcodec_open(self.CodecCtx, self.Codec)

    def close(self):
        """
           This closes the track. And thus closes the context."
        """
        if (self.CodecCtx!=NULL):
            avcodec_close(self.CodecCtx)
        self.CodecCtx=NULL

    def prepare_to_read_ahead(self):
        """
        In order to avoid delay during reading, our player try always
        to read a little bit of that is available ahead.
        """
        pass

    def reset_buffers(self):
        """
        This function is used on seek to reset everything.
        """
        self.pts=0
        self.last_pts=0
        self.last_dts=0
        if (self.CodecCtx!=NULL):
            avcodec_flush_buffers(self.CodecCtx)
        ## violent solution but the most efficient so far...
        if (self.reopen_codec_on_buffer_reset):
            self._reopencodec()

    #  cdef process_packet(self, AVPacket * pkt):
    #      print "FATAL : process_packet : Error This function is abstract and should never be called, it is likely that you compiled pyffmpeg with a too old version of pyffmpeg !!!"
    #      print "Try running 'easy_install -U cython' and rerun the pyffmpeg2 install"
    #      assert(False)

    def seek_to_seconds(self, seconds ):
        """ Seek to the specified time in seconds.

            Note that seeking is always bit more complicated when we want to be exact.
            * We do not use any precomputed index structure for seeking (which would make seeking exact)
            * Due to codec limitations, FFMPEG often provide approximative seeking capabilites
            * Sometimes "time data" in video file are invalid
            * Sometimes "seeking is simply not possible"

            We are working on improving our seeking capabilities.
        """
        pts = (<float>seconds) * (<float>AV_TIME_BASE)
        #pts=av_rescale(seconds*AV_TIME_BASE, self.stream.time_base.den, self.stream.time_base.num*AV_TIME_BASE)
        self.seek_to_pts(pts)

    def seek_to_pts(self,  long long int pts):
        """ Seek to the specified PTS

            Note that seeking is always bit more complicated when we want to be exact.
            * We do not use any precomputed index structure for seeking (which would make seeking exact)
            * Due to codec limitations, FFMPEG often provide approximative seeking capabilites
            * Sometimes "time data" in video file are invalid
            * Sometimes "seeking is simply not possible"

            We are working on improving our seeking capabilities.
        """

        if (self.start_time!=AV_NOPTS_VALUE):
            pts+=self.start_time


        self.vr.seek_to(pts)



cdef class AudioPacketDecoder:
    cdef uint8_t *audio_pkt_data
    cdef int audio_pkt_size

    cdef __new__(self):
        self.audio_pkt_data =<uint8_t *>NULL
        self.audio_pkt_size=0

    cdef int audio_decode_frame(self,  AVCodecContext *aCodecCtx,
            uint8_t *audio_buf,  int buf_size, double * pts_ptr, 
            double * audio_clock, int nchannels, int samplerate, AVPacket * pkt, int first) :
        cdef double pts
        cdef int n
        cdef int len1
        cdef int data_size

        
        data_size = buf_size
        #print "datasize",data_size
        len1 = avcodec_decode_audio3(aCodecCtx, <int16_t *>audio_buf, &data_size, pkt)
        if(len1 < 0) :
                raise IOError,("Audio decoding error (i)",len1)
        if(data_size < 0) :
                raise IOError,("Audio decoding error (ii)",data_size)

        #We have data, return it and come back for more later */
        pts = audio_clock[0]
        pts_ptr[0] = pts
        n = 2 * nchannels
        audio_clock[0] += ((<double>data_size) / (<double>(n * samplerate)))
        return data_size


###############################################################################
## The AudioTrack Class
###############################################################################


cdef class AudioTrack(Track):
    cdef object audioq   #< This queue memorize the data to be reagglomerated
    cdef object audiohq  #< This queue contains the audio packet for hardware devices
    cdef double clock    #< Just a clock
    cdef AudioPacketDecoder apd
    cdef float tps
    cdef int data_size
    cdef int rdata_size
    cdef int sdata_size
    cdef int dest_frame_overlap #< If you want to computer spectrograms it may be useful to have overlap in-between data
    cdef int dest_frame_size
    cdef int hardware_queue_len
    cdef object lf
    cdef int os
    cdef object audio_buf # buffer used in decoding of  audio

    def init(self, tps=30, hardware_queue_len=5, dest_frame_size=0, dest_frame_overlap=0, **args):
        """
        The "tps" denotes the assumed frame per seconds.
        This is use to synchronize the emission of audio packets with video packets.

        The hardware_queue_len, denotes the output audio queue len, in this queue all packets have a size determined by dest_frame_size or tps

        dest_frame_size specifies the size of desired audio frames,
        when dest_frame_overlap is not null some datas will be kept in between
        consecutive audioframes, this is useful for computing spectrograms.

        """
        assert (numpy!=None), "NumPy must be available for audio support to work. Please install numpy."
        Track.init(self,  **args)
        self.tps=tps
        self.hardware_queue_len=hardware_queue_len
        self.dest_frame_size=dest_frame_size
        self.dest_frame_overlap=dest_frame_overlap

        #
        # audiohq =
        # hardware queue : agglomerated and time marked packets of a specific size (based on audioq)
        #
        self.audiohq=AudioQueue(limitsz=self.hardware_queue_len)
        self.audioq=AudioQueue(limitsz=12,tps=self.tps,
                              samplerate=self.CodecCtx.sample_rate,
                              destframesize=self.dest_frame_size if (self.dest_frame_size!=0) else (self.CodecCtx.sample_rate//self.tps),
                              destframeoverlap=self.dest_frame_overlap,
                              destframequeue=self.audiohq)



        self.data_size=AVCODEC_MAX_AUDIO_FRAME_SIZE # ok let's try for try
        self.sdata_size=0
        self.rdata_size=self.data_size-self.sdata_size
        self.audio_buf=numpy.ones((AVCODEC_MAX_AUDIO_FRAME_SIZE,self.CodecCtx.channels),dtype=numpy.int16 )
        self.clock=0
        self.apd=AudioPacketDecoder()
        self.os=0
        self.lf=None

    def reset_tps(self,tps):
        self.tps=tps
        self.audiohq=AudioQueue(limitsz=self.hardware_queue_len)  # hardware queue : agglomerated and time marked packets of a specific size (based on audioq)
        self.audioq=AudioQueue(limitsz=12,tps=self.tps,
                              samplerate=self.CodecCtx.sample_rate,
                              destframesize=self.dest_frame_size if (self.dest_frame_size!=0) else (self.CodecCtx.sample_rate//self.tps),
#                              destframesize=self.dest_frame_size or (self.CodecCtx.sample_rate//self.tps),
                              destframeoverlap=self.dest_frame_overlap,
                              destframequeue=self.audiohq)


    def get_cur_pts(self):
        return self.last_pts

    def reset_buffers(self):
        ## violent solution but the most efficient so far...
        Track.reset_buffers(self)
        try:
            while True:
                self.audioq.get()
        except Queue_Empty:
            pass
        try:
            while True:
                self.audiohq.get()
        except Queue_Empty:
            pass
        self.apd=AudioPacketDecoder()

    def get_channels(self):
        """ Returns the number of channels of the AudioTrack."""
        return self.CodecCtx.channels

    def get_samplerate(self):
        """ Returns the samplerate of the AudioTrack."""
        return self.CodecCtx.sample_rate

    def get_audio_queue(self):
        """ Returns the audioqueue where received packets are agglomerated to form
            audio frames of the desired size."""
        return self.audioq

    def get_audio_hardware_queue(self):
        """ Returns the audioqueue where data are stored while waiting to be used by user."""
        return self.audiohq

    def __read_subsequent_audio(self):
        """ This function is used internally to do some read ahead.

        we will push in the audio queue the datas that appear after a specified frame,
        or until the audioqueue is full
        """
        calltrack=self.get_no()
        #DEBUG("read_subsequent_audio")
        if (self.vr.tracks[0].get_no()==self.get_no()):
            calltrack=-1
        self.vr.read_until_next_frame(calltrack=calltrack)
        #self.audioq.print_buffer_stats()

    cdef process_packet(self, AVPacket * pkt):
        cdef double xpts
        self.rdata_size=self.data_size
        lf=2
        audio_size=self.rdata_size*lf
	
        first=1
        #DEBUG( "process packet size=%s pts=%s dts=%s "%(str(pkt.size),str(pkt.pts),str(pkt.dts)))
        #while or if? (see version 2.0)
        if (audio_size>0):
            audio_size=self.rdata_size*lf
            audio_size = self.apd.audio_decode_frame(self.CodecCtx,
                                      <uint8_t *> <unsigned long long> (PyArray_DATA_content( self.audio_buf)),
                                      audio_size,
                                      &xpts,
                                      &self.clock,
                                      self.CodecCtx.channels,
                                      self.CodecCtx.sample_rate,
                                      pkt,
                                      first)
            first=0
            if (audio_size>0):
                self.os+=1
                audio_start=0
                len1 = audio_size
                bb= ( audio_start )//lf
                eb= ( audio_start +(len1//self.CodecCtx.channels) )//lf
                if pkt.pts == AV_NOPTS_VALUE:
                    pts = pkt.dts
                else:
                    pts = pkt.pts
                opts=pts
                #self.pts=pts
                self.last_pts=av_rescale(pkt.pts,AV_TIME_BASE * <int64_t>self.stream.time_base.num,self.stream.time_base.den)
                self.last_dts=av_rescale(pkt.dts,AV_TIME_BASE * <int64_t>self.stream.time_base.num,self.stream.time_base.den)
                xpts= av_rescale(pts,AV_TIME_BASE * <int64_t>self.stream.time_base.num,self.stream.time_base.den)
                xpts=float(pts)/AV_TIME_BASE
                cb=self.audio_buf[bb:eb].copy()
                self.lf=cb
                self.audioq.putforce((cb,pts,float(opts)/self.tps)) ## this audio q is for processing
                #print ("tp [%d:%d]/as:%d/bs:%d:"%(bb,eb,audio_size,self.Adata_size))+str(cb.mean())+","+str(cb.std())
                self.rdata_size=self.data_size
        if (self.observer):
            try:
                while (True) :
                    x=self.audiohq.get_nowait()
                    if (self.vr.observers_enabled):
                        self.observer(x)
            except Queue_Empty:
                pass

    def prepare_to_read_ahead(self):
        """ This function is used internally to do some read ahead """
        self.__read_subsequent_audio()

    def get_next_frame(self):
        """
        Reads a packet and return last decoded frame.

        NOTE : Usage of this function is discouraged for now.

        TODO : Check again this function
        """
        os=self.os
        #DEBUG("AudioTrack : get_next_frame")
        while (os==self.os):
            self.vr.read_packet()
        #DEBUG("/AudioTrack : get_next_frame")
        return self.lf

    def get_current_frame(self):
        """
          Reads audio packet so that the audioqueue contains enough data for
          one one frame, and then decodes that frame

          NOTE : Usage of this function is discouraged for now.

          TODO : this approximative yet
          TODO : this shall use the hardware queue
        """

        dur=int(self.get_samplerate()//self.tps)
        while (len(self.audioq)<dur):
            self.vr.read_packet()
        return self.audioq[0:dur]

    def print_buffer_stats(self):
        ##
        ##
        ##
        self.audioq.print_buffer_stats("audio queue")






###############################################################################
## The VideoTrack Class
###############################################################################


cdef class VideoTrack(Track):
    """
        VideoTrack implement a video codec to access the videofile.

        VideoTrack reads in advance up to videoframebanksz frames in the file.
        The frames are put in a temporary pool with their presentation time.
        When the next image is queried the system look at for the image the most likely to be the next one...
    """

    cdef int outputmode
    cdef PixelFormat pixel_format
    cdef int frameno
    cdef int videoframebanksz
    cdef object videoframebank ### we use this to reorder image though time
    cdef object videoframebuffers ### TODO : Make use of these buffers
    cdef int videobuffers
    cdef int hurried_frames
    cdef int width
    cdef int height
    cdef int dest_height
    cdef int dest_width
    cdef int with_motion_vectors
    cdef  SwsContext * convert_ctx




    def init(self, pixel_format=PIX_FMT_NONE, videoframebanksz=1, dest_width=-1, dest_height=-1,videobuffers=2,outputmode=OUTPUTMODE_NUMPY,with_motion_vectors=0,** args):
        """ Construct a video track decoder for a specified image format

            You may specify :

            pixel_format to force data to be in a specified pixel format.
            (note that only array like formats are supported, i.e. no YUV422)

            dest_width, dest_height in order to force a certain size of output

            outputmode : 0 for numpy , 1 for PIL

            videobuffers : Number of video buffers allocated
            videoframebanksz : Number of decoded buffers to be kept in memory

            It supports also the following parameted from ffmpeg
            skip_frame
            skip_idct
            skip_loop_filter
            dct_algo
            idct_algo

            To set all value for keyframes_only
            just set up hurry_mode to any value.

        """
        cdef int numBytes
        Track.init(self,  **args)
        self.outputmode=outputmode
        self.pixel_format=pixel_format
        if (self.pixel_format==PIX_FMT_NONE):
            self.pixel_format=PIX_FMT_RGB24
        self.videoframebank=[]
        self.videoframebanksz=videoframebanksz
        self.videobuffers=videobuffers
        self.with_motion_vectors=with_motion_vectors
        if self.with_motion_vectors:
            self.CodecCtx.debug = FF_DEBUG_MV | FF_DEBUG_MB_TYPE        
        self.width = self.CodecCtx.width
        self.height = self.CodecCtx.height
        self.dest_width=(dest_width==-1) and self.width or dest_width
        self.dest_height=(dest_height==-1) and self.height or dest_height
        numBytes=avpicture_get_size(self.pixel_format, self.dest_width, self.dest_height)
        #print  "numBytes", numBytes,self.pixel_format,
        if (outputmode==OUTPUTMODE_NUMPY):
            #print "shape", (self.dest_height, self.dest_width,numBytes/(self.dest_width*self.dest_height))
            self.videoframebuffers=[ numpy.zeros(shape=(self.dest_height, self.dest_width,
                                                        numBytes/(self.dest_width*self.dest_height)),  dtype=numpy.uint8)      for i in range(self.videobuffers) ]
        else:
            assert self.pixel_format==PIX_FMT_RGB24, "While using PIL only RGB pixel format is supported by pyffmpeg"
            self.videoframebuffers=[ Image.new("RGB",(self.dest_width,self.dest_height)) for i in range(self.videobuffers) ]
        self.convert_ctx = sws_getContext(self.width, self.height, self.CodecCtx.pix_fmt, self.dest_width,self.dest_height,self.pixel_format, SWS_BILINEAR, NULL, NULL, NULL)
        if self.convert_ctx == NULL:
            raise MemoryError("Unable to allocate scaler context")


    def reset_buffers(self):
        """ Reset the internal buffers. """

        Track.reset_buffers(self)
        for x in self.videoframebank:
            self.videoframebuffers.append(x[2])
        self.videoframebank=[]


    def print_buffer_stats(self):
        """ Display some informations on internal buffer system """

        print "video buffers :", len(self.videoframebank), " used out of ", self.videoframebanksz


    def get_cur_pts(self):

        return self.last_pts



    def get_orig_size(self) :
        """ return the size of the image in the current video track """

        return (self.width,  self.height)


    def get_size(self) :
        """ return the size of the image in the current video track """

        return (self.dest_width,  self.dest_height)


    def close(self):
        """ closes the track and releases the video decoder """

        Track.close(self)
        if (self.convert_ctx!=NULL):
            sws_freeContext(self.convert_ctx)
        self.convert_ctx=NULL


    cdef _read_current_macroblock_types(self, AVFrame *f):
        cdef int mb_width
        cdef int mb_height
        cdef int mb_stride

        mb_width = (self.width+15)>>4
        mb_height = (self.height+15)>>4
        mb_stride = mb_width + 1

        #if (self.CodecCtx.codec_id == CODEC_ID_MPEG2VIDEO) && (self.CodecCtx.progressive_sequence!=0)
        #    mb_height = (self.height + 31) / 32 * 2
        #elif self.CodecCtx.codec_id != CODEC_ID_H264
        #    mb_height = self.height + 15) / 16;

        res = numpy.zeros((mb_height,mb_width), dtype=numpy.uint32)

        if ((<void*>f.mb_type)==NULL):
            print "no mb_type available"
            return None           

        cdef int x,y
        for x in range(mb_width):
            for y in range(mb_height):
                res[y,x]=f.mb_type[x + y*mb_stride]
        return res


    cdef _read_current_motion_vectors(self,AVFrame * f):
        cdef int mv_sample_log2
        cdef int mb_width
        cdef int mb_height
        cdef int mv_stride

        mv_sample_log2 = 4 - f.motion_subsample_log2
        mb_width = (self.width+15)>>4
        mb_height = (self.height+15)>>4
        mv_stride = (mb_width << mv_sample_log2)
        if self.CodecCtx.codec_id != CODEC_ID_H264:
            mv_stride += 1
        res = numpy.zeros((mb_height<<mv_sample_log2,mb_width<<mv_sample_log2,2), dtype=numpy.int16)

        # TODO: support also backward prediction
        
        if ((<void*>f.motion_val[0])==NULL):
            print "no motion_val available"
            return None
        
        cdef int x,y,xydirection,preddirection    
        preddirection = 0
        for xydirection in range(2):
            for x in range(2*mb_width):
                for y in range(2*mb_height):
                    res[y,x,xydirection]=f.motion_val[preddirection][x + y*mv_stride][xydirection]
        return res


    cdef _read_current_ref_index(self, AVFrame *f):
        # HAS TO BE DEBUGGED
        cdef int mv_sample_log2
        cdef int mv_width
        cdef int mv_height
        cdef int mv_stride

        mv_sample_log2= 4 - f.motion_subsample_log2
        mb_width= (self.width+15)>>4
        mb_height= (self.height+15)>>4
        mv_stride= (mb_width << mv_sample_log2) + 1
        res = numpy.zeros((mb_height,mb_width,2), dtype=numpy.int8)

        # currently only forward predicition is supported
        if ((<void*>f.ref_index[0])==NULL):
            print "no ref_index available"
            return None

        cdef int x,y,xydirection,preddirection,mb_stride
        mb_stride = mb_width + 1
        
#00524     s->mb_stride = mb_width + 1;
#00525     s->b8_stride = s->mb_width*2 + 1;
#00526     s->b4_stride = s->mb_width*4 + 1;

        # currently only forward predicition is supported
        preddirection = 0
        for xydirection in range(2):
            for x in range(mb_width):
                for y in range(mb_height):
                     res[y,x]=f.ref_index[preddirection][x + y*mb_stride]
        return res
        
        
    cdef process_packet(self, AVPacket *packet):

        cdef int frameFinished=0
        ret = avcodec_decode_video2(self.CodecCtx,self.frame,&frameFinished,packet)
        #DEBUG( "process packet size=%s pts=%s dts=%s keyframe=%d picttype=%d"%(str(packet.size),str(packet.pts),str(packet.dts),self.frame.key_frame,self.frame.pict_type))
        if ret < 0:
                #DEBUG("IOError")
            raise IOError("Unable to decode video picture: %d" % (ret,))
        if (frameFinished):
            #DEBUG("frame finished")
            self.on_frame_finished()
        self.last_pts=av_rescale(packet.pts,AV_TIME_BASE * <int64_t>self.stream.time_base.num,self.stream.time_base.den)
        self.last_dts=av_rescale(packet.dts,AV_TIME_BASE * <int64_t>self.stream.time_base.num,self.stream.time_base.den)
        #DEBUG("/__nextframe")

    #########################################
    ### FRAME READING RELATED ISSUE
    #########################################


    def get_next_frame(self):
        """ reads the next frame and observe it if necessary"""

        #DEBUG("videotrack get_next_frame")
        self.__next_frame()
        #DEBUG("__next_frame done")
        am=self.smallest_videobank_time()
        #print am
        f=self.videoframebank[am][2]
        if (self.vr.observers_enabled):
            if (self.observer):
                self.observer(f)
        #DEBUG("/videotack get_next_frame")
        return f



    def get_current_frame(self):
        """ return the image with the smallest time index among the not yet displayed decoded frame """

        am=self.safe_smallest_videobank_time()
        return self.videoframebank[am]



    def _internal_get_current_frame(self):
        """
            This function is normally not aimed to be called by user it essentially does a conversion in-between the picture that is being decoded...
        """

        cdef AVFrame *pFrameRes
        cdef int numBytes
        if self.outputmode==OUTPUTMODE_NUMPY:
            img_image=self.videoframebuffers.pop()
            pFrameRes = self._convert_withbuf(<AVPicture *>self.frame,<char *><unsigned long long>PyArray_DATA_content(img_image))
        else:
            img_image=self.videoframebuffers.pop()
            bufferdata="\0"*(self.dest_width*self.dest_height*3)
            pFrameRes = self._convert_withbuf(<AVPicture *>self.frame,<char *>bufferdata)
            img_image.fromstring(bufferdata)
        av_free(pFrameRes)
        return img_image



    def _get_current_frame_without_copy(self,numpyarr):
        """
            This function is normally returns without copying it the image that is been read
            TODO: Make this work at the correct time (not at the position at the preload cursor)
        """

        cdef AVFrame *pFrameRes
        cdef int numBytes
        numBytes=avpicture_get_size(self.pixel_format, self.CodecCtx.width, self.CodecCtx.height)
        if (self.numpy):
            pFrameRes = self._convert_withbuf(<AVPicture *>self.frame,<char *><unsigned long long>PyArray_DATA_content(numpyarr))
        else:
            raise Exception, "Not yet implemented" # TODO : <



    def on_frame_finished(self):
        #DEBUG("on frame finished")
        if self.vr.packet.pts == AV_NOPTS_VALUE:
            pts = self.vr.packet.dts
        else:
            pts = self.vr.packet.pts
        self.pts = av_rescale(pts,AV_TIME_BASE * <int64_t>self.stream.time_base.num,self.stream.time_base.den)
        #print "unparsed pts", pts,  self.stream.time_base.num,self.stream.time_base.den,  self.pts
        self.frameno += 1
        pict_type = self.frame.pict_type
        if (self.with_motion_vectors):
            motion_vals = self._read_current_motion_vectors(self.frame)
            mb_type = self._read_current_macroblock_types(self.frame)
            ref_index = self._read_current_ref_index(self.frame)
        else:
            motion_vals = None
            mb_type = None
            ref_index = None
        self.videoframebank.append((self.pts, 
                                    self.frameno,
                                    self._internal_get_current_frame(),
                                    pict_type,
                                    mb_type,
                                    motion_vals,
                                    ref_index))
        # DEBUG this
        if (len(self.videoframebank)>self.videoframebanksz):
            self.videoframebuffers.append(self.videoframebank.pop(0)[2])
        #DEBUG("/on_frame_finished")

    def __next_frame(self):
        cdef int fno
        cfno=self.frameno
        while (cfno==self.frameno):
            #DEBUG("__nextframe : reading packet...")
            self.vr.read_packet()
        return self.pts
        #return av_rescale(pts,AV_TIME_BASE * <int64_t>Track.time_base.num,Track.time_base.den)






    ########################################
    ### videoframebank management
    #########################################

    def prefill_videobank(self):
        """ Use for read ahead : fill in the video buffer """

        if (len(self.videoframebank)<self.videoframebanksz):
            self.__next_frame()



    def refill_videobank(self,no=0):
        """ empty (partially) the videobank and refill it """

        if not no:
            for x in self.videoframebank:
                self.videoframebuffers.extend(x[2])
            self.videoframebank=[]
            self.prefill_videobank()
        else:
            for i in range(self.videoframebanksz-no):
                self.__next_frame()



    def smallest_videobank_time(self):
        """ returns the index of the frame in the videoframe bank that have the smallest time index """

        mi=0
        if (len(self.videoframebank)==0):
            raise Exception,"empty"
        vi=self.videoframebank[mi][0]
        for i in range(1,len(self.videoframebank)):
            if (vi<self.videoframebank[mi][0]):
                mi=i
                vi=self.videoframebank[mi][0]
        return mi



    def prepare_to_read_ahead(self):
        """ generic function called after seeking to prepare the buffer """
        self.prefill_videobank()


    ########################################
    ### misc
    #########################################

    def _finalize_seek(self, rtargetPts):
        while True:
            self.__next_frame()
#           if (self.debug_seek):
#             sys.stderr.write("finalize_seek : %d\n"%(self.pts,))
            if self.pts >= rtargetPts:
                break


    def set_hurry(self, b=1):
        #if we hurry it we can get bad frames later in the GOP
        if (b) :
            self.CodecCtx.skip_idct = AVDISCARD_BIDIR
            self.CodecCtx.skip_frame = AVDISCARD_BIDIR
            self.hurried_frames = 0
        else:
            self.CodecCtx.skip_idct = AVDISCARD_DEFAULT
            self.CodecCtx.skip_frame = AVDISCARD_DEFAULT

    ########################################
    ###
    ########################################


    cdef AVFrame *_convert_to(self,AVPicture *frame, PixelFormat pixformat=PIX_FMT_NONE):
        """ Convert AVFrame to a specified format (Intended for copy) """

        cdef AVFrame *pFrame
        cdef int numBytes
        cdef char *rgb_buffer
        cdef int width,height
        cdef AVCodecContext *pCodecCtx = self.CodecCtx

        if (pixformat==PIX_FMT_NONE):
            pixformat=self.pixel_format

        pFrame = avcodec_alloc_frame()
        if pFrame == NULL:
            raise MemoryError("Unable to allocate frame")
        width = self.dest_width
        height = self.dest_height
        numBytes=avpicture_get_size(pixformat, width,height)
        rgb_buffer = <char *>PyMem_Malloc(numBytes)
        avpicture_fill(<AVPicture *>pFrame, <uint8_t *>rgb_buffer, pixformat,width, height)
        sws_scale(self.convert_ctx, frame.data, frame.linesize, 0, self.height, <uint8_t **>pFrame.data, pFrame.linesize)
        if (pFrame==NULL):
            raise Exception,("software scale conversion error")
        return pFrame






    cdef AVFrame *_convert_withbuf(self,AVPicture *frame,char *buf,  PixelFormat pixformat=PIX_FMT_NONE):
        """ Convert AVFrame to a specified format (Intended for copy)  """

        cdef AVFrame *pFramePixFormat
        cdef int numBytes
        cdef int width,height
        cdef AVCodecContext *pCodecCtx = self.CodecCtx

        if (pixformat==PIX_FMT_NONE):
            pixformat=self.pixel_format

        pFramePixFormat = avcodec_alloc_frame()
        if pFramePixFormat == NULL:
            raise MemoryError("Unable to allocate Frame")

        width = self.dest_width
        height = self.dest_height
        avpicture_fill(<AVPicture *>pFramePixFormat, <uint8_t *>buf, self.pixel_format,   width, height)
        sws_scale(self.convert_ctx, frame.data, frame.linesize, 0, self.height, <uint8_t**>pFramePixFormat.data, pFramePixFormat.linesize)
        return pFramePixFormat


    # #########################################################
    # time  related functions
    # #########################################################

    def get_fps(self):
        """ return the number of frame per second of the video """
        return (<float>self.stream.r_frame_rate.num / <float>self.stream.r_frame_rate.den)

    def get_base_freq(self):
        """ return the base frequency of a file """
        return (<float>self.CodecCtx.time_base.den/<float>self.CodecCtx.time_base.num)

    def seek_to_frame(self, fno):
        fps=self.get_fps()
        dst=float(fno)/fps
        #sys.stderr.write( "seeking to %f seconds (fps=%f)\n"%(dst,fps))
        self.seek_to_seconds(dst)

    #        def GetFrameTime(self, timestamp):
    #           cdef int64_t targetPts
    #           targetPts = timestamp * AV_TIME_BASE
    #           return self.GetFramePts(targetPts)

    def safe_smallest_videobank_time(self):
        """ return the smallest time index among the not yet displayed decoded frame """
        try:
            return self.smallest_videobank_time()
        except:
            self.__next_frame()
            return self.smallest_videobank_time()

    def get_current_frame_pts(self):
        """ return the PTS for the frame with the smallest time index 
        among the not yet displayed decoded frame """
        am=self.safe_smallest_videobank_time()
        return self.videoframebank[am][0]

    def get_current_frame_frameno(self):
        """ return the frame number for the frame with the smallest time index 
        among the not yet displayed decoded frame """
        am=self.safe_smallest_videobank_time()
        return self.videoframebank[am][1]

    def get_current_frame_type(self):
        """ return the pict_type for the frame with the smallest time index 
        among the not yet displayed decoded frame """
        am=self.safe_smallest_videobank_time()
        return self.videoframebank[am][3]

    def get_current_frame_macroblock_types(self):
        """ return the motion_vals for the frame with the smallest time index 
        among the not yet displayed decoded frame """
        am=self.safe_smallest_videobank_time()
        return self.videoframebank[am][4]        

    def get_current_frame_motion_vectors(self):
        """ return the motion_vals for the frame with the smallest time index 
        among the not yet displayed decoded frame """
        am=self.safe_smallest_videobank_time()
        return self.videoframebank[am][5]        

    def get_current_frame_reference_index(self):
        """ return the motion_vals for the frame with the smallest time index 
        among the not yet displayed decoded frame """
        am=self.safe_smallest_videobank_time()
        return self.videoframebank[am][6]        

    def _get_current_frame_frameno(self):
        return self.CodecCtx.frame_number


    #def write_picture():
        #cdef int out_size
        #if (self.cframe == None):
                #self.CodecCtx.bit_rate = self.bitrate;
                #self.CodecCtx.width = self.width;
                #self.CodecCtx.height = self.height;
                #CodecCtx.frame_rate = (int)self.frate;
                #c->frame_rate_base = 1;
                #c->gop_size = self.gop;
                #c->me_method = ME_EPZS;

                #if (avcodec_open(c, codec) < 0):
                #        raise Exception, "Could not open codec"

                # Write header
                #av_write_header(self.oc);

                # alloc image and output buffer
                #pict = &pic1;
                #avpicture_alloc(pict,PIX_FMT_YUV420P, c->width,c->height);

                #outbuf_size = 1000000;
                #outbuf = "\0"*outbuf_size
                #avframe->linesize[0]=c->width*3;


        #avframe->data[0] = pixmap_;

        ### TO UPDATE
        #img_convert(pict,PIX_FMT_YUV420P, (AVPicture*)avframe, PIX_FMT_RGB24,c->width, c->height);


        ## ENCODE
        #out_size = avcodec_encode_video(c, outbuf, outbuf_size, (AVFrame*)pict);

        #if (av_write_frame(oc, 0, outbuf, out_size)):
        #        raise Exception, "Error while encoding picture"
        #cframe+=1


###############################################################################
## The Reader Class
###############################################################################

cdef class FFMpegReader(AFFMpegReader):
    """ A reader is responsible for playing the file demultiplexing it, and
        to passing the data of each stream to the corresponding track object.

    """
    cdef object default_audio_track
    cdef object default_video_track
    cdef int with_readahead
    cdef unsigned long long int seek_before_security_interval

    def __cinit__(self,with_readahead=True,seek_before=4000):
        self.filename = None
        self.tracks=[]
        self.ctracks=NULL
        self.FormatCtx=NULL
        self.io_context=NULL
        self.frameno = 0
        self.pts=0
        self.dts=0
        self.altpacket=0
        self.prepacket=NULL
        self.packet=&self.packetbufa
        self.observers_enabled=True
        self.errjmppts=0
        self.default_audio_track=None
        self.default_video_track=None
        self.with_readahead=with_readahead
        self.seek_before_security_interval=seek_before


    def __dealloc__(self):
        self.tracks=[]
        if (self.FormatCtx!=NULL):
            if (self.packet):
                av_free_packet(self.packet)
                self.packet=NULL
            if (self.prepacket):
                av_free_packet(self.prepacket)
                self.prepacket=NULL
            av_close_input_file(self.FormatCtx)
            self.FormatCtx=NULL


    def __del__(self):
        self.close()


    def dump(self):
        av_dump_format(self.FormatCtx,0,self.filename,0)


    #def open_old(self,char *filename,track_selector=None,mode="r"):

        #
        # Open the Multimedia File
        #

#        ret = av_open_input_file(&self.FormatCtx,filename,NULL,0,NULL)
#        if ret != 0:
#            raise IOError("Unable to open file %s" % filename)
#        self.filename = filename
#        if (mode=="r"):
#            self.__finalize_open(track_selector)
#        else:
#            self.__finalize_open_write()


    def open(self,char *filename,track_selector=None,mode="r",buf_size=1024):
        cdef int ret
        cdef int score
        cdef AVInputFormat * fmt
        cdef AVProbeData pd
        fmt=NULL
        pd.filename=filename
        pd.buf=NULL
        pd.buf_size=0

        self.filename = filename
        self.FormatCtx = avformat_alloc_context()

        if (mode=="w"):
            raise Exception,"Not yet supported sorry"
            self.FormatCtx.oformat = av_guess_format(NULL, filename_, NULL)
            if (self.FormatCtx.oformat==NULL):
                raise Exception, "Unable to find output format for %s\n"

        if (fmt==NULL):
            fmt=av_probe_input_format(&pd,0)
        
        if (fmt==NULL) or (not (fmt.flags & AVFMT_NOFILE)):
            ret = avio_open(&self.FormatCtx.pb, filename, 1)
            if ret < 0:
                raise IOError("Unable to open file %s (avio_open)" % filename)
            if (buf_size>0):
                url_setbufsize(self.FormatCtx.pb,buf_size)
            #raise Exception, "Not Yet Implemented"
            for log2_probe_size in range(11,20):
                probe_size=1<<log2_probe_size
                #score=(AVPROBE_SCORE_MAX/4 if log2_probe_size!=20 else 0)
                pd.buf=<unsigned char *>av_realloc(pd.buf,probe_size+AVPROBE_PADDING_SIZE)
                pd.buf_size=avio_read(self.FormatCtx.pb,pd.buf,probe_size)
                memset(pd.buf+pd.buf_size,0,AVPROBE_PADDING_SIZE)
                if (avio_seek(self.FormatCtx.pb,0,SEEK_SET)):
                    avio_close(self.FormatCtx.pb)
                    ret=avio_open(&self.FormatCtx.pb, filename, 0)
                    if (ret < 0):
                        raise IOError("Unable to open file %s (avio_open with but)" % filename)
                fmt=av_probe_input_format(&pd,1)#,&score)
                if (fmt!=NULL):
                    break

        assert(fmt!=NULL)
        self.FormatCtx.iformat=fmt

        if (mode=="r"):
            ret = av_open_input_stream(&self.FormatCtx,self.FormatCtx.pb,filename,self.FormatCtx.iformat,NULL)
            if ret != 0:
                raise IOError("Unable to open stream %s" % filename)
            self.__finalize_open(track_selector)
        elif (mode=="w"):
            ret=avio_open(&self.FormatCtx.pb, filename, 1)
            if ret != 0:
                raise IOError("Unable to open file %s" % filename)
            self.__finalize_open_write()
        else:
            raise ValueError, "Unknown Mode"


    def __finalize_open_write(self):
        """
         EXPERIMENTAL !
        """
        cdef  AVFormatContext * oc
        oc = avformat_alloc_context()
        # Guess file format with file extention
        oc.oformat = av_guess_format(NULL, filename_, NULL)
        if (oc.oformat==NULL):
            raise Exception, "Unable to find output format for %s\n"
        # Alloc priv_data for format
        oc.priv_data = av_mallocz(oc.oformat.priv_data_size)
        #avframe = avcodec_alloc_frame();



        # Create the video stream on output AVFormatContext oc
        #self.st = av_new_stream(oc,0)
        # Alloc the codec to the new stream
        #c = &self.st.codec
        # find the video encoder

        #codec = avcodec_find_encoder(oc.oformat.video_codec);
        #if (self.st.codec==None):
        #    raise Exception,"codec not found\n"
        #codec_name = <char *> codec.name;

        # Create the output file
        avio_open(&oc.pb, filename_, URL_WRONLY)

        # last part of init will be set when first frame write()
        # because we need user parameters like size, bitrate...
        self.mode = "w"


    def __finalize_open(self, track_selector=None):
        cdef AVCodecContext * CodecCtx
        cdef VideoTrack vt
        cdef AudioTrack at
        cdef int ret
        cdef int i

        if (track_selector==None):
            track_selector=TS_VIDEO
        ret = av_find_stream_info(self.FormatCtx)
        if ret < 0:
            raise IOError("Unable to find Track info: %d" % (ret,))

        self.pts=0
        self.dts=0

        self.altpacket=0
        self.prepacket=NULL
        self.packet=&self.packetbufa
        #
        # Open the selected Track
        #


        #for i in range(self.FormatCtx.nb_streams):
        #  print "stream #",i," codec_type:",self.FormatCtx.streams[i].codec.codec_type

        for s in track_selector.values():
            #print s
            trackno = -1
            trackb=s[1]
            if (trackb<0):
                for i in range(self.FormatCtx.nb_streams):
                    if self.FormatCtx.streams[i].codec.codec_type == s[0]:
                        if (trackb!=-1):
                            trackb+=1
                        else:
                            #DEBUG("associated "+str(s)+" to "+str(i))
                            #sys.stdin.readline()
                            trackno = i
                            break
            else:
                trackno=s[1]
                assert(trackno<self.FormatCtx.nb_streams)
                assert(self.FormatCtx.streams[i].codec.codec_type == s[0])
            if trackno == -1:
                raise IOError("Unable to find specified Track")

            CodecCtx = self.FormatCtx.streams[trackno].codec
            if (s[0]==AVMEDIA_TYPE_VIDEO):
                try:
                    vt=VideoTrack()
                except:
                    vt=VideoTrack(support_truncated=1)
                if (self.default_video_track==None):
                    self.default_video_track=vt
                vt.init0(self,trackno,  CodecCtx) ## here we are passing cpointers so we do a C call
                vt.init(**s[2])## here we do a python call
                self.tracks.append(vt)
            elif (s[0]==AVMEDIA_TYPE_AUDIO):
                try:
                    at=AudioTrack()
                except:
                    at=AudioTrack(support_truncated=1)
                if (self.default_audio_track==None):
                    self.default_audio_track=at
                at.init0(self,trackno,  CodecCtx) ## here we are passing cpointers so we do a C call
                at.init(**s[2])## here we do a python call
                self.tracks.append(at)
            else:
                raise "unknown type of Track"
        if (self.default_audio_track!=None and self.default_video_track!=None):
            self.default_audio_track.reset_tps(self.default_video_track.get_fps())
        for t in self.tracks:
            t.check_start() ### this is done only if asked
            savereadahead=self.with_readahead
            savebsi=self.seek_before_security_interval
            self.seek_before_security_interval=0
            self.with_readahead=0
            t.check_end()
            self.with_readahead=savereadahead
            self.seek_before_security_interval=savebsi
        try:
            if (self.tracks[0].duration()<0):
                sys.stderr.write("WARNING : inconsistent file duration %x\n"%(self.tracks[0].duration() ,))
                new_duration=-self.tracks[0].duration()
                self.tracks[0]._set_duration(new_duration)
        except KeyError:
            pass


    def close(self):
        if (self.FormatCtx!=NULL):
            for s in self.tracks:
                s.close()
            if (self.packet):
                av_free_packet(self.packet)
                self.packet=NULL
            if (self.prepacket):
                av_free_packet(self.prepacket)
                self.prepacket=NULL
            self.tracks=[] # break cross references
            av_close_input_file(self.FormatCtx)
            self.FormatCtx=NULL


    cdef __prefetch_packet(self):
        """ this function is used for prefetching a packet
            this is used when we want read until something new happen on a specified channel
        """
        #DEBUG("prefetch_packet")
        ret = av_read_frame(self.FormatCtx,self.prepacket)
        if ret < 0:
            #for xerrcnts in range(5,1000):
            #  if (not self.errjmppts):
            #      self.errjmppts=self.tracks[0].get_cur_pts()
            #  no=self.errjmppts+xerrcnts*(AV_TIME_BASE/50)
            #  sys.stderr.write("Unable to read frame:trying to skip some packet and trying again.."+str(no)+","+str(xerrcnts)+"...\n")
            #  av_seek_frame(self.FormatCtx,-1,no,0)
            #  ret = av_read_frame(self.FormatCtx,self.prepacket)
            #  if (ret!=-5):
            #      self.errjmppts=no
            #      print "solved : ret=",ret
            #      break
            #if ret < 0:
            raise IOError("Unable to read frame: %d" % (ret,))
        #DEBUG("/prefetch_packet")


    cdef read_packet_buggy(self):
        """
         This function is supposed to make things nicer...
         However, it is buggy right now and I have to check
         whether it is sitll necessary... So it will be re-enabled ontime...
        """
        cdef bint packet_processed=False
        #DEBUG("read_packet %d %d"%(long(<long int>self.packet),long(<long int>self.prepacket)))
        while not packet_processed:
                #ret = av_read_frame(self.FormatCtx,self.packet)
                #if ret < 0:
                #    raise IOError("Unable to read frame: %d" % (ret,))
            if (self.prepacket==NULL):
                self.prepacket=&self.packetbufa
                self.packet=&self.packetbufb
                self.__prefetch_packet()
            self.packet=self.prepacket
            if (self.packet==&self.packetbufa):
                self.prepacket=&self.packetbufb
            else:
                self.prepacket=&self.packetbufa
            #DEBUG("...PRE..")
            self.__prefetch_packet()
            #DEBUG("packets %d %d"%(long(<long int>self.packet),long(<long int>self.prepacket)))
            packet_processed=self.process_current_packet()
        #DEBUG("/read_packet")

    cdef read_packet(self):
        self.prepacket=&self.packetbufb
        ret = av_read_frame(self.FormatCtx,self.prepacket)
        if ret < 0:
            raise IOError("Unable to read frame: %d" % (ret,))
        self.packet=self.prepacket
        packet_processed=self.process_current_packet()


    def process_current_packet(self):
        """ This function implements the demuxes.
            It dispatch the packet to the correct track processor.

            Limitation : TODO: This function is to be improved to support more than audio and  video tracks.
        """
        cdef Track ct
        cdef VideoTrack vt
        cdef AudioTrack at
        #DEBUG("process_current_packet")
        processed=False
        for s in self.tracks:
            ct=s ## does passing through a pointer solves virtual issues...
            #DEBUG("track : %s = %s ??" %(ct.no,self.packet.stream_index))
            if (ct.no==self.packet.stream_index):
                #ct.process_packet(self.packet)
                ## I don't know why it seems that Windows Cython have problem calling the correct virtual function
                ##
                ##
                if ct.CodecCtx.codec_type==AVMEDIA_TYPE_VIDEO:
                    processed=True
                    vt=ct
                    vt.process_packet(self.packet)
                elif ct.CodecCtx.codec_type==AVMEDIA_TYPE_AUDIO:
                    processed=True
                    at=ct
                    at.process_packet(self.packet)
                else:
                    raise Exception, "Unknown codec type"
                    #ct.process_packet(self.packet)
                #DEBUG("/process_current_packet (ok)")
                av_free_packet(self.packet)
                self.packet=NULL
                return True
        #DEBUG("A packet tageted to track %d has not been processed..."%(self.packet.stream_index))
        #DEBUG("/process_current_packet (not processed !!)")
        av_free_packet(self.packet)
        self.packet=NULL
        return False

    def disable_observers(self):
        self.observers_enabled=False

    def enable_observers(self):
        self.observers_enabled=True

    def get_current_frame(self):
        r=[]
        for tt in self.tracks:
            r.append(tt.get_current_frame())
        return r


    def get_next_frame(self):
        self.tracks[0].get_next_frame()
        return self.get_current_frame()


    def __len__(self):
        try:
            return len(self.tracks[0])
        except:
            raise IOError,"File not correctly opened"


    def read_until_next_frame(self, calltrack=0,maxerrs=10, maxread=10):
        """ read all packets until a frame for the Track "calltrack" arrives """
        #DEBUG("read untiil next fame")
        try :
            while ((maxread>0)  and (calltrack==-1) or (self.prepacket.stream_index != (self.tracks[calltrack].get_no()))):
                if (self.prepacket==NULL):
                    self.prepacket=&self.packetbufa
                    self.packet=&self.packetbufb
                    self.__prefetch_packet()
                self.packet=self.prepacket
                cont=True
                #DEBUG("read until next frame iteration ")
                while (cont):
                    try:
                        self.__prefetch_packet()
                        cont=False
                    except KeyboardInterrupt:
                        raise
                    except:
                        maxerrs-=1
                        if (maxerrs<=0):
                            #DEBUG("read until next frame MAX ERR COUNTS REACHED... Raising Exception")
                            raise
                self.process_current_packet()
                maxread-=1
        except Queue_Full:
            #DEBUG("/read untiil next frame : QF")
            return False
        except IOError:
            #DEBUG("/read untiil next frame : IOError")
            sys.stderr.write("IOError")
            return False
        #DEBUG("/read until next frame")
        return True


    def get_tracks(self):
        return self.tracks


    def seek_to(self, pts):
        """
          Globally seek on all the streams to a specified position.
        """
        #sys.stderr.write("Seeking to PTS=%d\n"%pts)
        cdef int ret=0
        #av_read_frame_flush(self.FormatCtx)
        #DEBUG("FLUSHED")
        ppts=pts-self.seek_before_security_interval # seek a little bit before... and then manually go direct frame
        #ppts=pts
        #print ppts, pts
        #DEBUG("CALLING AV_SEEK_FRAME")

        #try:
        #  if (pts > self.tracks[0].duration()):
        #        raise IOError,"Cannot seek after the end...\n"
        #except KeyError:
        #  pass


        ret = av_seek_frame(self.FormatCtx,-1,ppts,  AVSEEK_FLAG_BACKWARD)#|AVSEEK_FLAG_ANY)
        #DEBUG("AV_SEEK_FRAME DONE")
        if ret < 0:
            raise IOError("Unable to seek: %d" % ret)
        #if (self.io_context!=NULL):
        #    #DEBUG("using FSEEK  ")
        #    #used to have & on pb
        # url_fseek(self.FormatCtx.pb, self.FormatCtx.data_offset, SEEK_SET);
        ## ######################################
        ## Flush buffer
        ## ######################################

        #DEBUG("resetting track buffers")
        for  s in self.tracks:
            s.reset_buffers()

        ## ######################################
        ## do set up exactly all tracks
        ## ######################################

        try:
            if (self.seek_before_security_interval):
            #DEBUG("finalize seek    ")
                self.disable_observers()
                self._finalize_seek_to(pts)
                self.enable_observers()
        except KeyboardInterrupt:
            raise
        except:
            DEBUG("Exception during finalize_seek")

        ## ######################################
        ## read ahead buffers
        ## ######################################
        if self.with_readahead:
            try:
                #DEBUG("readahead")
                self.prepare_to_read_ahead()
                #DEBUG("/readahead")
            except KeyboardInterrupt:
                raise
            except:
                DEBUG("Exception during read ahead")


        #DEBUG("/seek")

    def reset_buffers(self):
        for  s in self.tracks:
            s.reset_buffers()


    def _finalize_seek_to(self, pts):
        """
            This internal function set the player in a correct state after by waiting for information that
            happen after a specified PTS to effectively occur.
        """
        while(self.tracks[0].get_cur_pts()<pts):
            #sys.stderr.write("approx PTS:" + str(self.tracks[0].get_cur_pts())+"\n")
            #print "approx pts:", self.tracks[0].get_cur_pts()
            self.step()
        sys.stderr.write("result PTS:" + str(self.tracks[0].get_cur_pts())+"\n")
        #sys.stderr.write("result PTR hex:" + hex(self.tracks[0].get_cur_pts())+"\n")

    def seek_bytes(self, byte):
        cdef int ret=0
        av_read_frame_flush(self.FormatCtx)
        ret = av_seek_frame(self.FormatCtx,-1,byte,  AVSEEK_FLAG_BACKWARD|AVSEEK_FLAG_BYTE)#|AVSEEK_FLAG_ANY)
        if ret < 0:
            raise IOError("Unable to seek: %d" % (ret,))
        if (self.io_context!=NULL):
            # used to have & here
            avio_seek(self.FormatCtx.pb, self.FormatCtx.data_offset, SEEK_SET)
        ## ######################################
        ## Flush buffer
        ## ######################################


        if (self.packet):
            av_free_packet(self.packet)
            self.packet=NULL
        self.altpacket=0
        self.prepacket=NULL
        self.packet=&self.packetbufa
        for  s in self.tracks:
            s.reset_buffers()

        ## ##########################################################
        ## Put the buffer in a states that would make reading easier
        ## ##########################################################
        self.prepare_to_read_ahead()


    def __getitem__(self,int pos):
        fps=self.tracks[0].get_fps()
        self.seek_to((pos/fps)*AV_TIME_BASE)
        #sys.stderr.write("Trying to get frame\n")
        ri=self.get_current_frame()
        #sys.stderr.write("Ok\n")
        #sys.stderr.write("ri=%s\n"%(repr(ri)))
        return ri

    def prepare_to_read_ahead(self):
        """ fills in all buffers in the tracks so that all necessary datas are available"""
        for  s in self.tracks:
            s.prepare_to_read_ahead()

    def step(self):
        self.tracks[0].get_next_frame()

    def run(self):
        while True:
            #DEBUG("PYFFMPEG RUN : STEP")
            self.step()

    def print_buffer_stats(self):
        c=0
        for t in self.tracks():
            print "track ",c
            try:
                t.print_buffer_stats
            except KeyboardInterrupt:
                raise
            except:
                pass
            c=c+1

    def duration(self):
        if (self.FormatCtx.duration==0x8000000000000000):
            raise KeyError
        return self.FormatCtx.duration

    def duration_time(self):
        return float(self.duration())/ (<float>AV_TIME_BASE)


#cdef class FFMpegStreamReader(FFMpegReader):
   # """
   # This contains some experimental code not meant to be used for the moment
    #"""
#    def open_url(self,  char *filename,track_selector=None):
#        cdef AVInputFormat *format
#        cdef AVProbeData probe_data
#        cdef unsigned char tbuffer[65536]
#        cdef unsigned char tbufferb[65536]

        #self.io_context=av_alloc_put_byte(tbufferb, 65536, 0,<void *>0,<void *>0,<void *>0,<void *>0)  #<ByteIOContext*>PyMem_Malloc(sizeof(ByteIOContext))
        #IOString ios
#       URL_RDONLY=0
#        if (avio_open(&self.io_context, filename,URL_RDONLY ) < 0):
#            raise IOError, "unable to open URL"
#        print "Y"

#        url_fseek(self.io_context, 0, SEEK_SET);

#        probe_data.filename = filename;
#        probe_data.buf = tbuffer;
#        probe_data.buf_size = 65536;

        #probe_data.buf_size = get_buffer(&io_context, buffer, sizeof(buffer));
        #

#        url_fseek(self.io_context, 65535, SEEK_SET);
        #
        #format = av_probe_input_format(&probe_data, 1);
        #
        #            if (not format) :
        #                url_fclose(&io_context);
        #                raise IOError, "unable to get format for URL"

#        if (av_open_input_stream(&self.FormatCtx, self.io_context, NULL, NULL, NULL)) :
#            url_fclose(self.io_context);
#            raise IOError, "unable to open input stream"
#        self.filename = filename
#        self.__finalize_open(track_selector)
#        print "Y"




##################################################################################
# Legacy support for compatibility with PyFFmpeg version 1.0
##################################################################################
class VideoStream:
    def __init__(self):
        self.vr=FFMpegReader()
    def __del__(self):
        self.close()
    def open(self, *args, ** xargs ):
        xargs["track_selector"]=TS_VIDEO_PIL
        self.vr.open(*args, **xargs)
        self.tv=self.vr.get_tracks()[0]
    def close(self):
        self.vr.close()
        self.vr=None
    def GetFramePts(self, pts):
        self.tv.seek_to_pts(pts)
        return self.tv.get_current_frame()[2]
    def GetFrameNo(self, fno):
        self.tv.seek_to_frame(fno)
        return self.tv.get_current_frame()[2]
    def GetCurrentFrame(self, fno):
        return self.tv.get_current_frame()[2]
    def GetNextFrame(self, fno):
        return self.tv.get_next_frame()


##################################################################################
# Usefull constants
##################################################################################

##################################################################################
# ok libavcodec   53. 35. 0
# defined in libavcodec/avcodec.h for AVCodecContext.profile
class profileTypes:
    FF_PROFILE_UNKNOWN  = -99
    FF_PROFILE_RESERVED = -100

    FF_PROFILE_AAC_MAIN = 0
    FF_PROFILE_AAC_LOW  = 1
    FF_PROFILE_AAC_SSR  = 2
    FF_PROFILE_AAC_LTP  = 3

    FF_PROFILE_DTS         = 20
    FF_PROFILE_DTS_ES      = 30
    FF_PROFILE_DTS_96_24   = 40
    FF_PROFILE_DTS_HD_HRA  = 50
    FF_PROFILE_DTS_HD_MA   = 60

    FF_PROFILE_MPEG2_422    = 0
    FF_PROFILE_MPEG2_HIGH   = 1
    FF_PROFILE_MPEG2_SS     = 2
    FF_PROFILE_MPEG2_SNR_SCALABLE  = 3
    FF_PROFILE_MPEG2_MAIN   = 4
    FF_PROFILE_MPEG2_SIMPLE = 5

    FF_PROFILE_H264_CONSTRAINED = (1<<9)  # 8+1; constraint_set1_flag
    FF_PROFILE_H264_INTRA       = (1<<11) # 8+3; constraint_set3_flag

    FF_PROFILE_H264_BASELINE             = 66
    FF_PROFILE_H264_CONSTRAINED_BASELINE = (66|FF_PROFILE_H264_CONSTRAINED)
    FF_PROFILE_H264_MAIN                 = 77
    FF_PROFILE_H264_EXTENDED             = 88
    FF_PROFILE_H264_HIGH                 = 100
    FF_PROFILE_H264_HIGH_10              = 110
    FF_PROFILE_H264_HIGH_10_INTRA        = (110|FF_PROFILE_H264_INTRA)
    FF_PROFILE_H264_HIGH_422             = 122
    FF_PROFILE_H264_HIGH_422_INTRA       = (122|FF_PROFILE_H264_INTRA)
    FF_PROFILE_H264_HIGH_444             = 144
    FF_PROFILE_H264_HIGH_444_PREDICTIVE  = 244
    FF_PROFILE_H264_HIGH_444_INTRA       = (244|FF_PROFILE_H264_INTRA)
    FF_PROFILE_H264_CAVLC_444            = 44

##################################################################################
# ok libavutil    51. 22. 1
class mbTypes:
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

##################################################################################
# ok
class PixelFormats:
    PIX_FMT_NONE                    = -1
    PIX_FMT_YUV420P                 = 0
    PIX_FMT_YUYV422                 = 1
    PIX_FMT_RGB24                   = 2   
    PIX_FMT_BGR24                   = 3   
    PIX_FMT_YUV422P                 = 4   
    PIX_FMT_YUV444P                 = 5   
    PIX_FMT_YUV410P                 = 6   
    PIX_FMT_YUV411P                 = 7   
    PIX_FMT_GRAY8                   = 8   
    PIX_FMT_MONOWHITE               = 9 
    PIX_FMT_MONOBLACK               = 10 
    PIX_FMT_PAL8                    = 11    
    PIX_FMT_YUVJ420P                = 12 
    PIX_FMT_YUVJ422P                = 13  
    PIX_FMT_YUVJ444P                = 14  
    PIX_FMT_XVMC_MPEG2_MC           = 15
    PIX_FMT_XVMC_MPEG2_IDCT         = 16
    PIX_FMT_UYVY422                 = 17
    PIX_FMT_UYYVYY411               = 18
    PIX_FMT_BGR8                    = 19  
    PIX_FMT_BGR4                    = 20    
    PIX_FMT_BGR4_BYTE               = 21
    PIX_FMT_RGB8                    = 22     
    PIX_FMT_RGB4                    = 23     
    PIX_FMT_RGB4_BYTE               = 24
    PIX_FMT_NV12                    = 25     
    PIX_FMT_NV21                    = 26     

    PIX_FMT_ARGB                    = 27     
    PIX_FMT_RGBA                    = 28     
    PIX_FMT_ABGR                    = 29     
    PIX_FMT_BGRA                    = 30     

    PIX_FMT_GRAY16BE                = 31 
    PIX_FMT_GRAY16LE                = 32 
    PIX_FMT_YUV440P                 = 33 
    PIX_FMT_YUVJ440P                = 34 
    PIX_FMT_YUVA420P                = 35
    PIX_FMT_VDPAU_H264              = 36
    PIX_FMT_VDPAU_MPEG1             = 37
    PIX_FMT_VDPAU_MPEG2             = 38
    PIX_FMT_VDPAU_WMV3              = 39
    PIX_FMT_VDPAU_VC1               = 40
    PIX_FMT_RGB48BE                 = 41  
    PIX_FMT_RGB48LE                 = 42  

    PIX_FMT_RGB565BE                = 43 
    PIX_FMT_RGB565LE                = 44 
    PIX_FMT_RGB555BE                = 45 
    PIX_FMT_RGB555LE                = 46 

    PIX_FMT_BGR565BE                = 47 
    PIX_FMT_BGR565LE                = 48 
    PIX_FMT_BGR555BE                = 49 
    PIX_FMT_BGR555LE                = 50 

    PIX_FMT_VAAPI_MOCO              = 51
    PIX_FMT_VAAPI_IDCT              = 52
    PIX_FMT_VAAPI_VLD               = 53 

    PIX_FMT_YUV420P16LE             = 54 
    PIX_FMT_YUV420P16BE             = 55 
    PIX_FMT_YUV422P16LE             = 56 
    PIX_FMT_YUV422P16BE             = 57 
    PIX_FMT_YUV444P16LE             = 58 
    PIX_FMT_YUV444P16BE             = 59 
    PIX_FMT_VDPAU_MPEG4             = 60 
    PIX_FMT_DXVA2_VLD               = 61 

    PIX_FMT_RGB444BE                = 62
    PIX_FMT_RGB444LE                = 63 
    PIX_FMT_BGR444BE                = 64 
    PIX_FMT_BGR444LE                = 65 
    PIX_FMT_Y400A                   = 66 
