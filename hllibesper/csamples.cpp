#define HL_NAME(n) libesper_##n

#include "esper.h"
#include "csamples.hpp"
#include "utils.hpp"
#include <hl.h>

HL_PRIM void HL_NAME(setc_sample_waveform)(int index, varray* waveform) {
    float* _waveform = hl_aptr(waveform, float);
    cSamples[index].waveform = _waveform;
}
DEFINE_PRIM(_VOID, setc_sample_waveform, _I32 _ARR);

HL_PRIM void HL_NAME(setc_sample_pitch_deltas)(int index, varray* pitchDeltas) {
    int* _pitchDeltas = hl_aptr(pitchDeltas, int);
    cSamples[index].pitchDeltas = _pitchDeltas;
}
DEFINE_PRIM(_VOID, setc_sample_pitch_deltas, _I32 _ARR);

HL_PRIM void HL_NAME(setc_sample_pitch_markers)(int index, varray* pitchMarkers) {
    int* _pitchMarkers = hl_aptr(pitchMarkers, int);
    cSamples[index].pitchMarkers = _pitchMarkers;
}
DEFINE_PRIM(_VOID, setc_sample_pitch_markers, _I32 _ARR);

HL_PRIM void HL_NAME(setc_sample_pitch_marker_validity)(int index, vstring* pitchMarkerValidity) {
    cSamples[index].pitchMarkerValidity = hl_to_utf8(pitchMarkerValidity->bytes);
}
DEFINE_PRIM(_VOID, setc_sample_pitch_marker_validity, _I32 _STRING);

HL_PRIM void HL_NAME(setc_sample_specharm)(int index, varray* specharm) {
    float* _specharm = hl_aptr(specharm, float);
    cSamples[index].specharm = _specharm;
}
DEFINE_PRIM(_VOID, setc_sample_specharm, _I32 _ARR);

HL_PRIM void HL_NAME(setc_sample_avg_specharm)(int index, varray* avgSpecharm) {
    float* _avgSpecharm = hl_aptr(avgSpecharm, float);
    cSamples[index].avgSpecharm = _avgSpecharm;
}
DEFINE_PRIM(_VOID, setc_sample_avg_specharm, _I32 _ARR);

// Config setters
HL_PRIM void HL_NAME(setc_sample_config_length)(int index, int length) {
    cSamples[index].config.length = length;
}
DEFINE_PRIM(_VOID, setc_sample_config_length, _I32 _I32);

HL_PRIM void HL_NAME(setc_sample_config_batches)(int index, int batches) {
    cSamples[index].config.batches = batches;
}
DEFINE_PRIM(_VOID, setc_sample_config_batches, _I32 _I32);

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
    cSamples[index].config.tempWidth = temp_width;
}
DEFINE_PRIM(_VOID, setc_sample_config_temp_width, _I32 _I32);





HL_PRIM varray* HL_NAME(getc_sample_waveform)(int index) {
    return (varray*)cSamples[index].waveform;
}
DEFINE_PRIM(_ARR, getc_sample_waveform, _I32);

HL_PRIM varray* HL_NAME(getc_sample_pitch_deltas)(int index) {
    return (varray*)cSamples[index].pitchDeltas;
}
DEFINE_PRIM(_ARR, getc_sample_pitch_deltas, _I32);

HL_PRIM varray* HL_NAME(getc_sample_pitch_markers)(int index) {
    return (varray*)cSamples[index].pitchMarkers;
}
DEFINE_PRIM(_ARR, getc_sample_pitch_markers, _I32);

HL_PRIM vstring* HL_NAME(getc_sample_pitch_marker_validity)(int index) {
    return char_to_vstring(cSamples[index].pitchMarkerValidity);
}
DEFINE_PRIM(_STRING, getc_sample_pitch_marker_validity, _I32);

HL_PRIM varray* HL_NAME(getc_sample_specharm)(int index) {
    return (varray*)cSamples[index].specharm;
}
DEFINE_PRIM(_ARR, getc_sample_specharm, _I32);

HL_PRIM varray* HL_NAME(getc_sample_avg_specharm)(int index) {
    return (varray*)cSamples[index].avgSpecharm;
}
DEFINE_PRIM(_ARR, getc_sample_avg_specharm, _I32);

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
    return cSamples[index].config.tempWidth;
}
DEFINE_PRIM(_I32, getc_sample_config_temp_width, _I32);

HL_PRIM int HL_NAME(getc_samples_count)() {
    return cSamplesCount;
}
DEFINE_PRIM(_I32, getc_samples_count);




HL_PRIM void HL_NAME(pushc_sample)(varray* waveform, varray* pitchDeltas, varray* pitchMarkers, vstring* pitchMarkerValidity, varray* specharm, varray* avgSpecharm, int length, int batches, int pitchLength, int markerLength, int pitch, int isVoiced, int isPlosive, int useVariance, float expectedPitch, float searchRange, int tempWidth) {
    char* _pitchMarkerValidity = hl_to_utf8(pitchMarkerValidity->bytes);
    float* _waveform = hl_aptr(waveform, float);
    int* _pitchDeltas = hl_aptr(pitchDeltas, int);
    int* _pitchMarkers = hl_aptr(pitchMarkers, int);
    float* _specharm = hl_aptr(specharm, float);
    float* _avgSpecharm = hl_aptr(avgSpecharm, float);
    cSampleCfg sampleConfig = makeCSampleConfig(length, batches, pitchLength, markerLength, pitch, isVoiced, isPlosive, useVariance, expectedPitch, searchRange, tempWidth);
    cSample sample = makeCSample(_waveform, _pitchDeltas, _pitchMarkers, _pitchMarkerValidity, _specharm, _avgSpecharm, sampleConfig);
    int newSize = cSamplesCount + 1;
    cSample* newSamples = (cSample*)hl_gc_alloc_noptr(sizeof(cSample) * newSize);
    for (int i = 0; i < cSamplesCount; i++)
        newSamples[i] = cSamples[i];
    cSamples = newSamples;
    cSamplesCount = newSize;
}
DEFINE_PRIM(_VOID, pushc_sample, _ARR _ARR _ARR _STRING _ARR _ARR _I32 _I32 _I32 _I32 _I32 _I32 _I32 _I32 _F32 _F32 _I32);

HL_PRIM void HL_NAME(clearc_samples)() {
    memset(cSamples, 0, sizeof(cSample) * cSamplesCount);
    cSamplesCount = 0;
}
DEFINE_PRIM(_VOID, clearc_samples);