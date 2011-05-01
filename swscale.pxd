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

##################################################################################
# ok libswscale    0. 12. 0 
cdef extern from "libswscale/swscale.h":
    cdef enum:
        SWS_FAST_BILINEAR,
        SWS_BILINEAR,
        SWS_BICUBIC,
        SWS_X,
        SWS_POINT,
        SWS_AREA,
        SWS_BICUBLIN,
        SWS_GAUSS,
        SWS_SINC,
        SWS_LANCZOS,
        SWS_SPLINE

    struct SwsContext:
        pass

    struct SwsFilter:
        pass

    # deprecated use sws_alloc_context() and sws_init_context()
    SwsContext *sws_getContext(int srcW, int srcH, int srcFormat, int dstW, int dstH, int dstFormat, int flags,SwsFilter *srcFilter, SwsFilter *dstFilter, double *param)
    #SwsContext *sws_alloc_context()
    #int sws_init_context(struct SwsContext *sws_context, SwsFilter *srcFilter, SwsFilter *dstFilter)
    void sws_freeContext(SwsContext *swsContext)
    int sws_scale(SwsContext *context, uint8_t* src[], int srcStride[], int srcSliceY,int srcSliceH, uint8_t* dst[], int dstStride[])

