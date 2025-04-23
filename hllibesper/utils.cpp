#include "esper.h"

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