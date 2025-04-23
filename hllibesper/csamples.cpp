#define HL_NAME(n) libesper_##n

#include "esper.h"
#include "utils.h"
#include <hl.h>
#include <iostream>
#include <math.h>

static cSample* cSamples;
static int cSamplesCount = 0;

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

HL_PRIM void HL_NAME(setc_sample_pitch_marker_validity)(int index, vstring pitchMarkerValidity) {
    cSamples[index].pitchMarkerValidity = hl_to_utf8(pitchMarkerValidity->bytes);kj;
}
DEFINE_PRIM(_VOID, setc_sample_pitch_marker_validity, _I32 _ARR);

HL_PRIM void HL_NAME(setc_sample_specharm)(int index, float* specharm) {
    cSamples[index].specharm = specharm;
}
DEFINE_PRIM(_VOID, setc_sample_specharm, _I32 _ARR);

HL_PRIM void HL_NAME(setc_sample_avgSpecharm)(int index, float* avgSpecharm) {
    cSamples[index].avgSpecharm = avgSpecharm;
}
DEFINE_PRIM(_VOID, setc_sample_avgSpecharm, _I32 _ARR);

// Config setters
HL_PRIM void HL_NAME(setc_sample_config_length)(int index, int length) {
    cSamples[index].config.length = length;
}
DEFINE_PRIM(_VOID, setc_sample_config_length, _I32 _I32);

HL_PRIM void HL_NAME(setc_sample_config_batches)(int index, int batches) {
    cSamples[index].config.batches = batches;
}
DEFINE_PRIM(_VOID, setc_sample_config_length, _I32 _I32);

HL_PRIM void HL_NAME(setc_sample_config_pitch_length)(int index, int pitchLength) {
    cSamples[index].config.pitchLength = pitchLength;
}
DEFINE_PRIM(_VOID, setc_sample_config_pitch_length, _I32 _I32);

HL_PRIM void HL_NAME(setc_sample_config_marker_length)(int index, int markerLength) {
    cSamples[index].config.markerLength = markerLength;
}
DEFINE_PRIM(_VOID, setc_sample_config_marker_length, _I32 _I32);

HL_PRIM void HL_NAME(setc_sample_config_pitch)(int index, int pitch) {
    cSamples[index].config.pitch = pitch;
}
DEFINE_PRIM(_VOID, setc_sample_config_pitch, _I32 _I32);

HL_PRIM void HL_NAME(setc_sample_config_is_voiced)(int index, int isVoiced) {
    cSamples[index].config.isVoiced = isVoiced;
}
DEFINE_PRIM(_VOID, setc_sample_config_is_voiced, _I32 _I32);

HL_PRIM void HL_NAME(setc_sample_config_is_plosive)(int index, int isPlosive) {
    cSamples[index].config.isPlosive = isPlosive;
}
DEFINE_PRIM(_VOID, setc_sample_config_is_plosive, _I32 _I32);

HL_PRIM void HL_NAME(setc_sample_config_use_variance)(int index, int useVariance) {
    cSamples[index].config.useVariance = useVariance;
}
DEFINE_PRIM(_VOID, setc_sample_config_use_variance, _I32 _I32);

HL_PRIM void HL_NAME(setc_sample_config_expected_pitch)(int index, float expectedPitch) {
    cSamples[index].config.expectedPitch = expectedPitch;
}
DEFINE_PRIM(_VOID, setc_sample_config_expected_pitch, _I32 _F32);

HL_PRIM void HL_NAME(setc_sample_config_search_range)(int index, float searchRange) {
    cSamples[index].config.searchRange = searchRange;
}
DEFINE_PRIM(_VOID, setc_sample_config_search_range, _I32 _F32);

HL_PRIM void HL_NAME(setc_sample_config_temp_width)(int index, int temp_width) {
    cSamples[index].config.temp_width = temp_width;
}
DEFINE_PRIM(_VOID, setc_sample_config_temp_width, _I32 _I32);





HL_PRIM float* HL_NAME(getc_sample_waveform)(int index) {
    return cSamples[index].waveform;
}
DEFINE_PRIM(_ARR, getc_sample_waveform, _I32);

HL_PRIM int* HL_NAME(getc_sample_pitchDeltas)(int index) {
    return cSamples[index].pitchDeltas;
}
DEFINE_PRIM(_ARR, getc_sample_pitchDeltas, _I32);

HL_PRIM int* HL_NAME(getc_sample_pitchMarkers)(int index) {
    return cSamples[index].pitchMarkers;
}
DEFINE_PRIM(_ARR, getc_sample_pitchMarkers, _I32);

HL_PRIM vstring HL_NAME(getc_sample_pitch_marker_validity)(int index) {
    return hl_copy_utf8(cSamples[index].pitchMarkerValidity);
}
DEFINE_PRIM(_STRING, getc_sample_pitch_marker_validity, _I32);

HL_PRIM float* HL_NAME(getc_sample_specharm)(int index) {
    return cSamples[index].specharm;
}
DEFINE_PRIM(_ARR, getc_sample_specharm, _I32);

HL_PRIM float* HL_NAME(getc_sample_avgSpecharm)(int index) {
    return cSamples[index].avgSpecharm;
}
DEFINE_PRIM(_ARR, getc_sample_avgSpecharm, _I32);

// Config getters
HL_PRIM int HL_NAME(getc_sample_config_length)(int index) {
    return cSamples[index].config.length;
}
DEFINE_PRIM(_I32, getc_sample_config_length, _I32);

HL_PRIM int HL_NAME(getc_sample_config_batches)(int index) {
    return cSamples[index].config.batches;
}
DEFINE_PRIM(_I32, getc_sample_config_batches, _I32);

HL_PRIM int HL_NAME(getc_sample_config_pitch_length)(int index) {
    return cSamples[index].config.pitchLength;
}
DEFINE_PRIM(_I32, getc_sample_config_pitch_length, _I32);

HL_PRIM int HL_NAME(getc_sample_config_marker_length)(int index) {
    return cSamples[index].config.markerLength;
}
DEFINE_PRIM(_I32, getc_sample_config_marker_length, _I32);

HL_PRIM int HL_NAME(getc_sample_config_pitch)(int index) {
    return cSamples[index].config.pitch;
}
DEFINE_PRIM(_I32, getc_sample_config_pitch, _I32);

HL_PRIM int HL_NAME(getc_sample_config_is_voiced)(int index) {
    return cSamples[index].config.isVoiced;
}
DEFINE_PRIM(_I32, getc_sample_config_is_voiced, _I32);

HL_PRIM int HL_NAME(getc_sample_config_is_plosive)(int index) {
    return cSamples[index].config.isPlosive;
}
DEFINE_PRIM(_I32, getc_sample_config_is_plosive, _I32);

HL_PRIM int HL_NAME(getc_sample_config_use_variance)(int index) {
    return cSamples[index].config.useVariance;
}
DEFINE_PRIM(_I32, getc_sample_config_use_variance, _I32);

HL_PRIM float HL_NAME(getc_sample_config_expected_pitch)(int index) {
    return cSamples[index].config.expectedPitch;
}
DEFINE_PRIM(_F32, getc_sample_config_expected_pitch, _I32);

HL_PRIM float HL_NAME(getc_sample_config_search_range)(int index) {
    return cSamples[index].config.searchRange;
}
DEFINE_PRIM(_F32, getc_sample_config_search_range, _I32);

HL_PRIM int HL_NAME(getc_sample_config_temp_width)(int index) {
    return cSamples[index].config.temp_width;
}
DEFINE_PRIM(_I32, getc_sample_config_temp_width, _I32);





HL_PRIM void HL_NAME(pushc_sample)(float* waveform, int* pitchDeltas, int* pitchMarkers, vstring pitchMarkerValidity, float* specharm, float* avgSpecharm, int length, int batches, int pitchLength, int markerLength, int pitch, int isVoiced, int isPlosive, int useVariance, float expectedPitch, float searchRange, int tempWidth) {
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