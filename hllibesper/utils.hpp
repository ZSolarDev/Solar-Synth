#pragma once

#include <hl.h>

extern "C" {
	cSampleCfg makeCSampleConfig(int length, int batches, int pitchLength, int markerLength, int pitch, int isVoiced, int isPlosive, int useVariance, float expectedPitch, float searchRange, int tempWidth);
	cSample makeCSample(float* waveform, int* pitchDeltas, int* pitchMarkers, char* pitchMarkerValidity, float* specharm, float* avgSpecharm, cSampleCfg config);
	segmentTiming makeSegmentTiming(int start1, int start2, int start3, int end1, int end2, int end3, int windowStart, int windowEnd, int offset);
	vstring* char_to_vstring(char* cstr);
}