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

from avutil cimport *
from avcodec cimport *

##################################################################################
# ok libavformat  52.102. 0 
cdef extern from "libavformat/avio.h":
    
    struct AVIOContext:
        unsigned char *buffer
        int buffer_size
        unsigned char *buf_ptr, *buf_end
        void *opaque
        int *read_packet
        int *write_packet
        int64_t *seek
        int64_t pos #< position in the file of the current buffer 
        int must_flush #< true if the next seek should flush 
        int eof_reached #< true if eof reached 
        int write_flag  #< true if open for writing 
        int is_streamed
        int max_packet_size
        unsigned long checksum
        unsigned char *checksum_ptr
        unsigned long *update_checksum
        int error         #< contains the error code or 0 if no error happened
        int *read_pause
        int64_t *read_seek

    
    int url_setbufsize(AVIOContext *s, int buf_size)
    int url_ferror(AVIOContext *s)
    int avio_open(AVIOContext **s, char *url, int flags)    
    int avio_close(AVIOContext *s)
    int avio_read(AVIOContext *s, unsigned char *buf, int size)
    int64_t avio_seek(AVIOContext *s, int64_t offset, int whence)    
    AVIOContext *avio_alloc_context(
                      unsigned char *buffer,
                      int buffer_size,
                      int write_flag,
                      void *opaque,
                      void *a,
                      void *b,
                      void *c)
    
    #struct ByteIOContext:
    #    pass
    #ctypedef long long int  offset_t

    #int get_buffer(ByteIOContext *s, unsigned char *buf, int size)
    # use avio_read(s, buf, size);
    
    #int url_ferror(ByteIOContext *s)
    # use int url_ferror(AVIOContext *s)

    #int url_feof(ByteIOContext *s)
    # use AVIOContext.eof_reached 
    
    #int url_fopen(ByteIOContext **s,  char *filename, int flags)
    # use avio_open(s, filename, flags);    
    
    #int url_setbufsize(ByteIOContext *s, int buf_size)
    #use int url_setbufsize(AVIOContext *s, int buf_size);

    #int url_fclose(ByteIOContext *s)
    # use avio_close(s)
    
    #long long int url_fseek(ByteIOContext *s, long long int offset, int whence)
    # use avio_seek(s, offset, whence);
    
    #    ByteIOContext *av_alloc_put_byte(
    #                  unsigned char *buffer,
    #                  int buffer_size,
    #                  int write_flag,
    #                  void *opaque,
    #                  void * a , void * b , void * c)
    #                  #int (*read_packet)(void *opaque, uint8_t *buf, int buf_size),
    #                  #int (*write_packet)(void *opaque, uint8_t *buf, int buf_size),
    #                  #offset_t (*seek)(void *opaque, offset_t offset, int whence))
    # use avio_alloc_context(buffer, buffer_size, write_flag, opaque,
    #                           read_packet, write_packet, seek);               
    
    
##################################################################################
# ok libavformat  52.102. 0
cdef extern from "libavformat/avformat.h":

    enum:    
        AVSEEK_FLAG_BACKWARD = 1 #< seek backward
        AVSEEK_FLAG_BYTE     = 2 #< seeking based on position in bytes
        AVSEEK_FLAG_ANY      = 4 #< seek to any frame, even non-keyframes
        AVSEEK_FLAG_FRAME    = 8 #< seeking based on frame number
    
    struct AVFrac:
        int64_t val, num, den

    struct AVProbeData:
        char *filename
        unsigned char *buf
        int buf_size

    struct AVCodecParserContext:
        pass

    struct AVIndexEntry:
        int64_t pos
        int64_t timestamp
        int flags
        int size
        int min_distance
    
    struct AVMetadataConv:
        pass
    
    struct AVMetadata:
        pass
    
    struct AVCodecTag:
        pass
    
    enum AVStreamParseType:
        AVSTREAM_PARSE_NONE,
        AVSTREAM_PARSE_FULL,       #< full parsing and repack */
        AVSTREAM_PARSE_HEADERS,    #< Only parse headers, do not repack. */
        AVSTREAM_PARSE_TIMESTAMPS, #< full parsing and interpolation of timestamps for frames not starting on a packet boundary */
        AVSTREAM_PARSE_FULL_ONCE    
    
    struct AVPacketList:
        AVPacket pkt
        AVPacketList *next

    struct AVOutputFormat:
        char *name
        char *long_name
        char *mime_type
        char *extensions
        int priv_data_size
        CodecID video_codec
        CodecID audio_codec
        int *write_header
        int *write_packet
        int *write_trailer
        # can use flags: AVFMT_NOFILE, AVFMT_NEEDNUMBER, AVFMT_RAWPICTURE,
        # AVFMT_GLOBALHEADER, AVFMT_NOTIMESTAMPS, AVFMT_VARIABLE_FPS,
        # AVFMT_NODIMENSIONS, AVFMT_NOSTREAMS
        int flags
        int *set_parameters        
        int *interleave_packet
        AVCodecTag **codec_tag
        CodecID subtitle_codec
        AVMetadataConv *metadata_conv
        void *priv_class
        AVOutputFormat *next

    struct AVInputFormat:
        char *name            #< A comma separated list of short names for the format
        char *long_name       #< Descriptive name for the format, meant to be more human-readable than name  
        int priv_data_size    #< Size of private data so that it can be allocated in the wrapper    
        char *mime_type       #< 
        int *read_probe
        int *read_header
        int *read_packet
        int *read_close
        int *read_seek
        int64_t *read_timestamp
        int flags
        char *extensions       #< If extensions are defined, then no probe is done
        int value
        int *read_play
        int *read_pause
        AVCodecTag **codec_tag        
        int *read_seek2
        AVMetadataConv *metadata_conv
        AVInputFormat *next


    struct AVStream:
        int index    #/* Track index in AVFormatContext */
        int id       #/* format specific Track id */
        AVCodecContext *codec #/* codec context */
        # real base frame rate of the Track.
        # for example if the timebase is 1/90000 and all frames have either
        # approximately 3600 or 1800 timer ticks then r_frame_rate will be 50/1
        AVRational r_frame_rate
        void *priv_data
        # internal data used in av_find_stream_info()
        int64_t first_dts # was codec_info_duration
        AVFrac pts
        # this is the fundamental unit of time (in seconds) in terms
        # of which frame timestamps are represented. for fixed-fps content,
        # timebase should be 1/framerate and timestamp increments should be
        # identically 1.
        AVRational time_base
        int pts_wrap_bits # number of bits in pts (used for wrapping control)
        # ffmpeg.c private use
        int stream_copy   # if TRUE, just copy Track
        AVDiscard discard       # < selects which packets can be discarded at will and dont need to be demuxed
        # FIXME move stuff to a flags field?
        # quality, as it has been removed from AVCodecContext and put in AVVideoFrame
        # MN:dunno if thats the right place, for it
        float quality
        # decoding: position of the first frame of the component, in
        # AV_TIME_BASE fractional seconds.
        int64_t start_time
        # decoding: duration of the Track, in AV_TIME_BASE fractional
        # seconds.
        int64_t duration
        char language[4] # ISO 639 3-letter language code (empty string if undefined)
        # av_read_frame() support
        AVStreamParseType need_parsing                  # < 1.full parsing needed, 2.only parse headers dont repack
        AVCodecParserContext *parser
        int64_t cur_dts
        int last_IP_duration
        int64_t last_IP_pts
        # av_seek_frame() support
        AVIndexEntry *index_entries # only used if the format does not support seeking natively
        int nb_index_entries
        int index_entries_allocated_size
        int64_t nb_frames                 # < number of frames in this Track if known or 0
        int64_t unused[4+1]        
        char *filename                  #< source filename of the stream 
        int disposition
        AVProbeData probe_data
        int64_t pts_buffer[16+1]
        AVRational sample_aspect_ratio
        AVMetadata *metadata
        uint8_t *cur_ptr
        int cur_len
        AVPacket cur_pkt
        int64_t reference_dts
        int probe_packets
        AVPacketList *last_in_packet_buffer
        AVRational avg_frame_rate        
        int codec_info_nb_frames
        pass

    enum:
        # for AVFormatContext.streams
        MAX_STREAMS = 20

        # for AVFormatContext.flags
        AVFMT_FLAG_GENPTS      = 0x0001 #< Generate missing pts even if it requires parsing future frames.
        AVFMT_FLAG_IGNIDX      = 0x0002 #< Ignore index.
        AVFMT_FLAG_NONBLOCK    = 0x0004 #< Do not block when reading packets from input.
        AVFMT_FLAG_IGNDTS      = 0x0008 #< Ignore DTS on frames that contain both DTS & PTS
        AVFMT_FLAG_NOFILLIN    = 0x0010 #< Do not infer any values from other values, just return what is stored in the container
        AVFMT_FLAG_NOPARSE     = 0x0020 #< Do not use AVParsers, you also must set AVFMT_FLAG_NOFILLIN as the fillin code works on frames and no parsing -> no frames. Also seeking to frames can not work if parsing to find frame boundaries has been disabled
        AVFMT_FLAG_RTP_HINT    = 0x0040 #< Add RTP hinting to the output file


    struct AVPacketList:
        pass


    struct AVProgram:
        pass


    struct AVChapter:
        pass


    struct AVFormatContext:
        void *              av_class
        AVInputFormat *     iformat
        AVOutputFormat *    oformat
        void *              priv_data
        AVIOContext *       pb
        unsigned int        nb_streams
        AVStream *          streams[20]        #< MAX_STREAMS == 20
        char                filename[1024]
        int64_t             timestamp
        int                 ctx_flags        #< Format-specific flags, see AVFMTCTX_xx, private data for pts handling (do not modify directly)
        AVPacketList *      packet_buffer
        int64_t             start_time
        int64_t             duration
        int64_t             file_size        # decoding: total file size. 0 if unknown
        int                 bit_rate        # decoding: total Track bitrate in bit/s, 0 if not

        #  av_read_frame() support
        AVStream *cur_st
        uint8_t *cur_ptr_deprecated
        int cur_len_deprecated
        AVPacket cur_pkt_deprecated
        int64_t data_offset #< offset of the first packet 
        int index_built
        
        int mux_rate
        unsigned int packet_size
        int preload
        int max_delay
        int loop_output
        int flags                         #< see AVFMT_FLAG_xxx
        int loop_input
        unsigned int probesize            #< decoding: size of data to probe; encoding: unused.
        int max_analyze_duration          #<  Maximum time (in AV_TIME_BASE units) during which the input should be analyzed in av_find_stream_info()
        uint8_t *key        
        int keylen
        unsigned int nb_programs
        AVProgram **programs
        CodecID video_codec_id            #< Demuxing: Set by user. Forced video codec_id
        CodecID audio_codec_id            #< Demuxing: Set by user. Forced audio codec_id
        CodecID subtitle_codec_id         #< Demuxing: Set by user. Forced subtitle codec_id
        #     * Maximum amount of memory in bytes to use for the index of each stream.
        #     * If the index exceeds this size, entries will be discarded as
        #     * needed to maintain a smaller size. This can lead to slower or less
        #     * accurate seeking (depends on demuxer).
        #     * Demuxers for which a full in-memory index is mandatory will ignore
        #     * this.
        #     * muxing  : unused
        #     * demuxing: set by user
        unsigned int max_index_size
        #     * Maximum amount of memory in bytes to use for buffering frames
        #     * obtained from realtime capture devices.
        unsigned int max_picture_buffer

        unsigned int nb_chapters
        AVChapter **chapters

        int debug                            #< FF_FDEBUG_TS        0x0001

        AVPacketList *raw_packet_buffer
        AVPacketList *raw_packet_buffer_end
        AVPacketList *packet_buffer_end
        
        AVMetadata *metadata
        
        int raw_packet_buffer_remaining_size
        
        int64_t start_time_realtime        
        
        
    struct AVInputFormat:
        pass


    struct AVFormatParameters:
        pass


    AVOutputFormat *av_guess_format(char *short_name,
                                char *filename,
                                char *mime_type)

    CodecID av_guess_codec(AVOutputFormat *fmt, char *short_name,
                           char *filename, char *mime_type,
                           AVMediaType type)

    # * Initialize libavformat and register all the muxers, demuxers and
    # * protocols. If you do not call this function, then you can select
    # * exactly which formats you want to support.
    void av_register_all()
    
    # * Find AVInputFormat based on the short name of the input format.
    AVInputFormat *av_find_input_format(char *short_name)

    # * Guess the file format.
    # *
    # * @param is_opened Whether the file is already opened; determines whether
    # *                  demuxers with or without AVFMT_NOFILE are probed.
    AVInputFormat *av_probe_input_format(AVProbeData *pd, int is_opened)

    # * Guess the file format.
    # *
    # * @param is_opened Whether the file is already opened; determines whether
    # *                  demuxers with or without AVFMT_NOFILE are probed.
    # * @param score_max A probe score larger that this is required to accept a
    # *                  detection, the variable is set to the actual detection
    # *                  score afterwards.
    # *                  If the score is <= AVPROBE_SCORE_MAX / 4 it is recommended
    # *                  to retry with a larger probe buffer.
    AVInputFormat *av_probe_input_format2(AVProbeData *pd, int is_opened, int *score_max)

    # * Allocate all the structures needed to read an input stream.
    # *        This does not open the needed codecs for decoding the stream[s].
    int av_open_input_stream(AVFormatContext **ic_ptr,
                         AVIOContext *pb, char *filename,
                         AVInputFormat *fmt, AVFormatParameters *ap)

    # * Open a media file as input. The codecs are not opened. Only the file
    # * header (if present) is read.
    # *
    # * @param ic_ptr The opened media file handle is put here.
    # * @param filename filename to open
    # * @param fmt If non-NULL, force the file format to use.
    # * @param buf_size optional buffer size (zero if default is OK)
    # * @param ap Additional parameters needed when opening the file
    # *           (NULL if default).
    # * @return 0 if OK, AVERROR_xxx otherwise
    int av_open_input_file(AVFormatContext **ic_ptr, char *filename,
                       AVInputFormat *fmt, int buf_size,
                       AVFormatParameters *ap)

    # * Read packets of a media file to get stream information. This
    # * is useful for file formats with no headers such as MPEG. This
    # * function also computes the real framerate in case of MPEG-2 repeat
    # * frame mode.
    # * The logical file position is not changed by this function;
    # * examined packets may be buffered for later processing.
    # *
    # * @param ic media file handle
    # * @return >=0 if OK, AVERROR_xxx on error
    # * @todo Let the user decide somehow what information is needed so that
    # *       we do not waste time getting stuff the user does not need.
    int av_find_stream_info(AVFormatContext *ic)
    
    # * Read a transport packet from a media file.
    # *
    # * This function is obsolete and should never be used.
    # * Use av_read_frame() instead.
    # *
    # * @param s media file handle
    # * @param pkt is filled
    # * @return 0 if OK, AVERROR_xxx on error
    int av_read_packet(AVFormatContext *s, AVPacket *pkt)
 
    # * Return the next frame of a stream.
    # * This function returns what is stored in the file, and does not validate
    # * that what is there are valid frames for the decoder. It will split what is
    # * stored in the file into frames and return one for each call. It will not
    # * omit invalid data between valid frames so as to give the decoder the maximum
    # * information possible for decoding.
    # *
    # * The returned packet is valid
    # * until the next av_read_frame() or until av_close_input_file() and
    # * must be freed with av_free_packet. For video, the packet contains
    # * exactly one frame. For audio, it contains an integer number of
    # * frames if each frame has a known fixed size (e.g. PCM or ADPCM
    # * data). If the audio frames have a variable size (e.g. MPEG audio),
    # * then it contains one frame.
    # *
    # * pkt->pts, pkt->dts and pkt->duration are always set to correct
    # * values in AVStream.time_base units (and guessed if the format cannot
    # * provide them). pkt->pts can be AV_NOPTS_VALUE if the video format
    # * has B-frames, so it is better to rely on pkt->dts if you do not
    # * decompress the payload.
    # *
    # * @return 0 if OK, < 0 on error or end of file
    int av_read_frame(AVFormatContext *s, AVPacket *pkt)
    
    # * Seek to the keyframe at timestamp.
    # * 'timestamp' in 'stream_index'.
    # * @param stream_index If stream_index is (-1), a default
    # * stream is selected, and timestamp is automatically converted
    # * from AV_TIME_BASE units to the stream specific time_base.
    # * @param timestamp Timestamp in AVStream.time_base units
    # *        or, if no stream is specified, in AV_TIME_BASE units.
    # * @param flags flags which select direction and seeking mode
    # * @return >= 0 on success
    int av_seek_frame(AVFormatContext *s, int stream_index, int64_t timestamp,
                  int flags)
    
    # * Start playing a network-based stream (e.g. RTSP stream) at the
    # * current position.
    int av_read_play(AVFormatContext *s)

    # * Pause a network-based stream (e.g. RTSP stream).
    # * Use av_read_play() to resume it.
    int av_read_pause(AVFormatContext *s)
    
    # * Free a AVFormatContext allocated by av_open_input_stream.
    # * @param s context to free
    void av_close_input_stream(AVFormatContext *s)

    # * Close a media file (but not its codecs).
    # * @param s media file handle
    void av_close_input_file(AVFormatContext *s)

    # * Add a new stream to a media file.
    # *
    # * Can only be called in the read_header() function. If the flag
    # * AVFMTCTX_NOHEADER is in the format context, then new streams
    # * can be added in read_packet too.
    # *
    # * @param s media file handle
    # * @param id file-format-dependent stream ID
    AVStream *av_new_stream(AVFormatContext *s, int id)
    AVProgram *av_new_program(AVFormatContext *s, int id)

    
    int av_find_default_stream_index(AVFormatContext *s)
    
    # * Get the index for a specific timestamp.
    # * @param flags if AVSEEK_FLAG_BACKWARD then the returned index will correspond
    # *                 to the timestamp which is <= the requested one, if backward
    # *                 is 0, then it will be >=
    # *              if AVSEEK_FLAG_ANY seek to any frame, only keyframes otherwise
    # * @return < 0 if no such timestamp could be found
    int av_index_search_timestamp(AVStream *st, int64_t timestamp, int flags)    

    # * Add an index entry into a sorted list. Update the entry if the list
    # * already contains it.
    # *
    # * @param timestamp timestamp in the time base of the given stream
    int av_add_index_entry(AVStream *st, int64_t pos, int64_t timestamp,
                       int size, int distance, int flags)

    # * Perform a binary search using av_index_search_timestamp() and
    # * AVInputFormat.read_timestamp().
    # * This is not supposed to be called directly by a user application,
    # * but by demuxers.
    # * @param target_ts target timestamp in the time base of the given stream
    # * @param stream_index stream number
    int av_seek_frame_binary(AVFormatContext *s, int stream_index,
                         int64_t target_ts, int flags)

    
    void av_dump_format(AVFormatContext *ic,
                    int index,
                    char *url,
                    int is_output)

    # * Allocate an AVFormatContext.
    # * avformat_free_context() can be used to free the context and everything
    # * allocated by the framework within it.
    AVFormatContext *avformat_alloc_context()


