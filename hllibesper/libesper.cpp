#define HL_NAME(n) libesper_##n

#include "esper.h"
#include <hl.h>
#include <iostream>
#include <math.h>

cSampleCfg makeCSampleConfig(int length, int batches, int pitchLength, int markerLength, int pitch, int isVoiced, int isPlosive, int useVariance, float expectedPitch, float searchRange, int tempWidth)
{
        cSampleCfg sampleConfig = { length, batches };
        return sampleConfig;
}

cSample makeCSample(float* waveform, int* pitchDeltas int* pitchMarkers, char* pitchMarkerValidity, float* specharm, float* avgSpecharm, cSampleCfg config)
{
        cSample sample = { waveform, pitchDeltas, pitchMarkers, pitchMarkerValidity, specharm, avgSpecharm, config };
        return sample;
}
