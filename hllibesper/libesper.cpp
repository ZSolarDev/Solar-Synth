#define HL_NAME(n) libesper_##n

#include "esper.h"
#include <hl.h>
#include <iostream>
#include <math.h>
#include "engineconfig.cpp"

static cSample* cSamples;
static int cSamplesCount = 0;

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

HL_PRIM void HL_NAME(setc_sample_waveform)(int index, float* waveform) {
    cSamples[index].waveform = waveform;
}
DEFINE_PRIM(_VOID, setc_sample_waveform, _I32 _ARR);

HL_PRIM void HL_NAME(setc_sample_pitchDeltas)(int index, int* pitchDeltas) {
    cSamples[index].pitchDeltas = pitchDeltas;
}
DEFINE_PRIM(_VOID, setc_sample_pitchDeltas, _I32 _ARR);

HL_PRIM void HL_NAME(setc_sample_pitchMarkers)(int index, int* pitchMarkers) {
    cSamples[index].pitchMarkers = pitchMarkers;
}
DEFINE_PRIM(_VOID, setc_sample_pitchMarkers, _I32 _ARR);

HL_PRIM void HL_NAME(setc_sample_waveform)(int index, float* waveform) {
    cSamples[index].waveform = waveform;
}
DEFINE_PRIM(_VOID, setc_sample_waveform, _I32 _ARR);

HL_PRIM void HL_NAME(setc_sample_specharm)(int index, float* specharm) {
    cSamples[index].specharm = specharm;
}
DEFINE_PRIM(_VOID, setc_sample_specharm, _I32 _ARR);

HL_PRIM void HL_NAME(setc_sample_avgSpecharm)(int index, float* avgSpecharm) {
    cSamples[index].avgSpecharm = avgSpecharm;
}
DEFINE_PRIM(_VOID, setc_sample_avgSpecharm, _I32 _ARR);

HL_PRIM void HL_NAME(pushc_sample)(float* waveform, int* pitchDeltas, int* pitchMarkers, vstring* pitchMarkerValidity, float* specharm, float* avgSpecharm, int length, int batches, int pitchLength, int markerLength, int pitch, int isVoiced, int isPlosive, int useVariance, float expectedPitch, float searchRange, int tempWidth) {
    const char* _pitchMarkerValidity = hl_to_utf8(pitchMarkerValidity->bytes);
    cSampleCfg sampleConfig = makeCSampleConfig(length, batches, pitchLength, markerLength, pitch, isVoiced, isPlosive, useVariance, expectedPitch, searchRange, tempWidth);
    cSample sample = makeCSample(waveform, pitchDeltas, pitchMarkers, _pitchMarkerValidity, specharm, avgSpecharm, sampleConfig);
    int newSize = cSamplesCount + 1;
    cSample* newSamples = (cSample*)hl_gc_alloc_noptr(sizeof(cSample) * newSize);
    for (int i = 0; i < cSamplesCount; i++)
        newSamples[i] = cSamples[i];
    cSamples = newSamples;
    cSamplesCount = newSize;
}
DEFINE_PRIM(_VOID, pushc_sample, _ARR _ARR _ARR _STRING _ARR _ARR _I32 _I32 _I32 _I32 _I32 _I32 _I32 _I32 _I32 _F32 _F32 _I32);

HL_PRIM void HL_NAME(clearc_samples)() {
    memset(cSamples, 0, sizeof(cSample) * cSamplesCount);
    cSamplesCount = 0;
}
DEFINE_PRIM(_VOID, clearc_samples);

HL_PRIM void HL_NAME(pitch_calc_fallback)() {
    pitchCalcFallback(cSamples, cfg);
}
DEFINE_PRIM(_VOID, pitch_calc_fallback);

HL_PRIM void HL_NAME(spec_calc)(float* waveform, int* pitchDeltas, int* pitchMarkers, vstring* pitchMarkerValidity, float* specharm, float* avgSpecharm, int length, int batches, int pitchLength, int markerLength, int pitch, int isVoiced, int isPlosive, int useVariance, float expectedPitch, float searchRange, int tempWidth) {
    const char* _pitchMarkerValidity = hl_to_utf8(pitchMarkerValidity->bytes);
    cSampleCfg sampleConfig = makeCSampleConfig(length, batches, pitchLength, markerLength, pitch, isVoiced, isPlosive, useVariance, expectedPitch, searchRange, tempWidth);
    cSample sample = makeCSample(waveform, pitchDeltas, pitchMarkers, _pitchMarkerValidity, specharm, avgSpecharm, sampleConfig);
    specCalc(sample, cfg);
}
DEFINE_PRIM(_VOID, spec_calc, _ARR _ARR _ARR _STRING _ARR _ARR _I32 _I32 _I32 _I32 _I32 _I32 _I32 _I32 _I32 _F32 _F32 _I32);

HL_PRIM void HL_NAME(resample_specharm)(float* avgSpecharm, float* specharm, int length, float* steadiness, float spacing, int startCap, int endCap, float* output, int start1, int start2, int start3, int end1, int end2, int end3, int windowStart, int windowEnd, int offset) {
    segmentTiming segTiming = makeSegmentTiming(start1, start2, start3, end1, end2, end3, windowStart, windowEnd, offset);
    resampleSpecharm(avgSpecharm, specharm, length, steadiness, spacing, startCap, endCap, output, segTiming, cfg);
}
DEFINE_PRIM(_VOID, resample_specharm, _ARR _ARR _I32 _ARR _F32 _I32 _I32 _ARR _I32 _I32 _I32 _I32 _I32 _I32 _I32 _I32 _I32);

HL_PRIM void HL_NAME(resample_pitch)(int* pitchDeltas, int length, float pitch, float spacing, int startCap, int endCap, float* output, int requiredSize, int start1, int start2, int start3, int end1, int end2, int end3, int windowStart, int windowEnd, int offset) {
    segmentTiming segTiming = makeSegmentTiming(start1, start2, start3, end1, end2, end3, windowStart, windowEnd, offset);
    resamplePitch(pitchDeltas, length, pitch, spacing, startCap, endCap, output, requiredSize, segTiming);
}
DEFINE_PRIM(_VOID, resample_pitch, _ARR _I32 _F32 _F32 _F32 _I32 _I32 _ARR _I32 _I32 _I32 _I32 _I32 _I32 _I32 _I32 _I32 _I32);

HL_PRIM void HL_NAME(apply_breathiness)(float* specharm, float* breathiness, int length) {
    applyBreathiness(specharm, breathiness, length, cfg);
}
DEFINE_PRIM(_VOID, apply_breathiness, _ARR _ARR _I32);

HL_PRIM void HL_NAME(pitch_shift)(float* specharm, float* srcPitch, float* tgtPitch, float* formantShift, float* breathiness, int length) {
    pitchShift(specharm, srcPitch, tgtPitch, formantShift, breathiness, length, cfg);
}
DEFINE_PRIM(_VOID, pitch_shift, _ARR _ARR _ARR _ARR _ARR _I32);

HL_PRIM void HL_NAME(apply_dynamics)(float* specharm, float* dynamics, float* pitch, int length) {
    applyDynamics(specharm, dynamics, pitch, length, cfg);
}
DEFINE_PRIM(_VOID, apply_dynamics, _ARR _ARR _ARR _I32);

HL_PRIM void HL_NAME(apply_brightness)(float* specharm, float* brightness, int length) {
    applyBrightness(specharm, brightness, length, cfg);
}
DEFINE_PRIM(_VOID, apply_brightness, _ARR _ARR _I32);

HL_PRIM void HL_NAME(apply_growl)(float* specharm, float* growl, float* lfoPhase, int length) {
    applyGrowl(specharm, growl, lfoPhase, length, cfg);
}
DEFINE_PRIM(_VOID, apply_growl, _ARR _ARR _ARR _I32);

HL_PRIM void HL_NAME(apply_roughness)(float* specharm, float* roughness, int length) {
    applyRoughness(specharm, roughness, length, cfg);
}
DEFINE_PRIM(_VOID, apply_roughness, _ARR _ARR _I32);

HL_PRIM void HL_NAME(render_unvoiced)(float* specharm, float* target, int length) {
    renderUnvoiced(specharm, target, length, cfg);
}
DEFINE_PRIM(_VOID, render_unvoiced, _ARR _ARR _I32);

HL_PRIM void HL_NAME(render_voiced)(float* specharm, float* pitch, float* phase, float* target, int length) {
        renderVoiced(specharm, pitch, phase, target, length cfg);
}
DEFINE_PRIM(_VOID, render_voiced, _ARR _ARR _ARR _ARR _I32);

HL_PRIM void HL_NAME(render)(float* specharm, float* pitch, float* phase, float* target, int length) {
    render(specharm, pitch, phase, target, length cfg);
}
DEFINE_PRIM(_VOID, render, _ARR _ARR _ARR _ARR _I32);