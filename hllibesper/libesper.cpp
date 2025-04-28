#define HL_NAME(n) libesper_##n

#include "esper.h"
#include <hl.h>
#include <iostream>
#include "utils.hpp"
#include "csamples.hpp"
#include "engineconfig.hpp"

HL_PRIM void HL_NAME(pitch_calc_fallback)() {
    pitchCalcFallback(cSamples, cfg);
}
DEFINE_PRIM(_VOID, pitch_calc_fallback);

HL_PRIM void HL_NAME(spec_calc)(varray* waveform, varray* pitchDeltas, varray* pitchMarkers, vstring* pitchMarkerValidity, varray* specharm, varray* avgSpecharm, int length, int batches, int pitchLength, int markerLength, int pitch, int isVoiced, int isPlosive, int useVariance, float expectedPitch, float searchRange, int tempWidth) {
    char* _pitchMarkerValidity = hl_to_utf8(pitchMarkerValidity->bytes);
    float* _waveform = hl_aptr(waveform, float);
    int* _pitchDeltas = hl_aptr(pitchDeltas, int);
    int* _pitchMarkers = hl_aptr(pitchMarkers, int);
    float* _specharm = hl_aptr(specharm, float);
    float* _avgSpecharm = hl_aptr(avgSpecharm, float);
    cSampleCfg sampleConfig = makeCSampleConfig(length, batches, pitchLength, markerLength, pitch, isVoiced, isPlosive, useVariance, expectedPitch, searchRange, tempWidth);
    cSample sample = makeCSample(_waveform, _pitchDeltas, _pitchMarkers, _pitchMarkerValidity, _specharm, _avgSpecharm, sampleConfig);;
    specCalc(sample, cfg);
}
DEFINE_PRIM(_VOID, spec_calc, _ARR _ARR _ARR _STRING _ARR _ARR _I32 _I32 _I32 _I32 _I32 _I32 _I32 _I32 _F32 _F32 _I32);

HL_PRIM void HL_NAME(resample_specharm)(varray* specharm, varray* avgSpecharm, int length, varray* steadiness, float spacing, int startCap, int endCap, varray* output, int start1, int start2, int start3, int end1, int end2, int end3, int windowStart, int windowEnd, int offset) {
    float* _specharm = hl_aptr(specharm, float);
    float* _avgSpecharm = hl_aptr(avgSpecharm, float);
    float* _steadiness = hl_aptr(steadiness, float);
    float* _output = hl_aptr(output, float);
    segmentTiming segTiming = makeSegmentTiming(start1, start2, start3, end1, end2, end3, windowStart, windowEnd, offset);
    resampleSpecharm(_avgSpecharm, _specharm, length, _steadiness, spacing, startCap, endCap, _output, segTiming, cfg);
}
DEFINE_PRIM(_VOID, resample_specharm, _ARR _ARR _I32 _ARR _F32 _I32 _I32 _ARR _I32 _I32 _I32 _I32 _I32 _I32 _I32 _I32 _I32);

HL_PRIM void HL_NAME(resample_pitch)(varray* pitchDeltas, int length, float pitch, float spacing, int startCap, int endCap, varray* output, int requiredSize, int start1, int start2, int start3, int end1, int end2, int end3, int windowStart, int windowEnd, int offset) {
    int* _pitchDeltas = hl_aptr(pitchDeltas, int);
    float* _output = hl_aptr(pitchDeltas, float);
    segmentTiming segTiming = makeSegmentTiming(start1, start2, start3, end1, end2, end3, windowStart, windowEnd, offset);
    resamplePitch(_pitchDeltas, length, pitch, spacing, startCap, endCap, _output, requiredSize, segTiming);
}
DEFINE_PRIM(_VOID, resample_pitch, _ARR _I32 _F32 _F32 _I32 _I32 _ARR _I32 _I32 _I32 _I32 _I32 _I32 _I32 _I32 _I32 _I32);

HL_PRIM void HL_NAME(apply_breathiness)(varray* specharm, varray* breathiness, int length) {
    float* _specharm = hl_aptr(specharm, float);
    float* _breathiness = hl_aptr(breathiness, float);
    applyBreathiness(_specharm, _breathiness, length, cfg);
}
DEFINE_PRIM(_VOID, apply_breathiness, _ARR _ARR _I32);

HL_PRIM void HL_NAME(pitch_shift)(varray* specharm, varray* srcPitch, varray* tgtPitch, varray* formantShift, varray* breathiness, int length) {
    float* _specharm = hl_aptr(specharm, float);
    float* _srcPitch = hl_aptr(srcPitch, float);
    float* _tgtPitch = hl_aptr(tgtPitch, float);
    float* _formantShift = hl_aptr(formantShift, float);
    float* _breathiness = hl_aptr(breathiness, float);
    pitchShift(_specharm, _srcPitch, _tgtPitch, _formantShift, _breathiness, length, cfg);
}
DEFINE_PRIM(_VOID, pitch_shift, _ARR _ARR _ARR _ARR _ARR _I32);

HL_PRIM void HL_NAME(apply_dynamics)(varray* specharm, varray* dynamics, varray* pitch, int length) {
    float* _specharm = hl_aptr(specharm, float);
    float* _dynamics = hl_aptr(dynamics, float);
    float* _pitch = hl_aptr(pitch, float);
    applyDynamics(_specharm, _dynamics, _pitch, length, cfg);
}
DEFINE_PRIM(_VOID, apply_dynamics, _ARR _ARR _ARR _I32);

HL_PRIM void HL_NAME(apply_brightness)(varray* specharm, varray* brightness, int length) {
    float* _specharm = hl_aptr(specharm, float);
    float* _brightness = hl_aptr(brightness, float);
    applyBrightness(_specharm, _brightness, length, cfg);
}
DEFINE_PRIM(_VOID, apply_brightness, _ARR _ARR _I32);

HL_PRIM void HL_NAME(apply_growl)(varray* specharm, varray* growl, varray* lfoPhase, int length) {
    float* _specharm = hl_aptr(specharm, float);
    float* _growl = hl_aptr(growl, float);
    float* _lfoPhase = hl_aptr(lfoPhase, float);
    applyGrowl(_specharm, _growl, _lfoPhase, length, cfg);
}
DEFINE_PRIM(_VOID, apply_growl, _ARR _ARR _ARR _I32);

HL_PRIM void HL_NAME(apply_roughness)(varray* specharm, varray* roughness, int length) {
    float* _specharm = hl_aptr(specharm, float);
    float* _roughness = hl_aptr(roughness, float);
    applyRoughness(_specharm, _roughness, length, cfg);
}
DEFINE_PRIM(_VOID, apply_roughness, _ARR _ARR _I32);

HL_PRIM void HL_NAME(render_unvoiced)(varray* specharm, varray* target, int length) {
    float* _specharm = hl_aptr(specharm, float);
    float* _target = hl_aptr(target, float);
    renderUnvoiced(_specharm, _target, length, cfg);
}
DEFINE_PRIM(_VOID, render_unvoiced, _ARR _ARR _I32);

HL_PRIM void HL_NAME(render_voiced)(varray* specharm, varray* pitch, varray* phase, varray* target, int length) {
    float* _specharm = hl_aptr(specharm, float);
    float* _target = hl_aptr(target, float);
    float* _phase = hl_aptr(phase, float);
    float* _pitch = hl_aptr(pitch, float);
    renderVoiced(_specharm, _pitch, _phase, _target, length, cfg);
}
DEFINE_PRIM(_VOID, render_voiced, _ARR _ARR _ARR _ARR _I32);

HL_PRIM void HL_NAME(render)(varray* specharm, varray* pitch, varray* phase, varray* target, int length) {
    float* _specharm = hl_aptr(specharm, float);
    float* _target = hl_aptr(target, float);
    float* _phase = hl_aptr(phase, float);
    float* _pitch = hl_aptr(pitch, float);
    render(_specharm, _pitch, _phase, _target, length, cfg);
}
DEFINE_PRIM(_VOID, render, _ARR _ARR _ARR _ARR _I32);
