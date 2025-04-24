#include "esper.h"
#include "utils.hpp"
#include <hl.h>

cSampleCfg makeCSampleConfig(int length, int batches, int pitchLength, int markerLength, int pitch, int isVoiced, int isPlosive, int useVariance, float expectedPitch, float searchRange, int tempWidth)
{
    cSampleCfg sampleConfig = { length, batches, pitchLength, markerLength, pitch, isVoiced, isPlosive, useVariance, expectedPitch, searchRange, tempWidth };
    return sampleConfig;
}

cSample makeCSample(float* waveform, int* pitchDeltas, int* pitchMarkers, char* pitchMarkerValidity, float* specharm, float* avgSpecharm, cSampleCfg config)
{
    cSample sample = { waveform, pitchDeltas, pitchMarkers, pitchMarkerValidity, specharm, avgSpecharm, config };
    return sample;
}

segmentTiming makeSegmentTiming(int start1, int start2, int start3, int end1, int end2, int end3, int windowStart, int windowEnd, int offset)
{
    segmentTiming segTiming = { start1, start2, start3, end1, end2, end3, windowStart, windowEnd, offset };
    return segTiming;
}

vstring* char_to_vstring(char* cstr) {
    if (cstr == NULL)
        return NULL;
    vstring* vs = (vstring*)hl_gc_alloc(&hlt_bytes, sizeof(vstring));
    vs->t = &hlt_bytes;
    vs->bytes = (uchar*)hl_to_utf16(cstr);
    vs->length = ustrlen(vs->bytes);

    return vs;
}