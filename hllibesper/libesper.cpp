#define HL_NAME(n) libesper_##n

#include "esper.h"
#include <hl.h>
#include <iostream>
#include "utils.hpp"
#include "csamples.hpp"
#include "engineconfig.hpp"
#include <map>
#include <string>
#include <vector>

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

struct resamplerArgs
{
    std::string rsmpDir;
    std::string inputPath;
    std::string outputPath;
    int pitch;
    float velocity;
    std::map<std::string, int> flags;
    float offset;
    int length;
    float consonant;
    float cutoff;
    float volume;
    float modulation;
    float tempo;
    std::vector<int> pitchBend;
};

//generates frequency and amplitude arrays from a sample's pitchDeltas and waveform attributes
//The result is intended to be written to a .frq file.
void getFrqFromSample(cSample& sample, std::vector<double>& frequencies, std::vector<double>& amplitudes, engineCfg config)
{
    frequencies.clear();
    amplitudes.clear();
    int srcLength = sample.config.pitchLength;
    int tgtLength = config.sampleRate / 256;
    for (int i = 0; i < tgtLength; i++) {
        double tgtIndex = (double)i / tgtLength * srcLength;
        int srcIndex = (int)tgtIndex;
        double srcWeight = tgtIndex - srcIndex;
        if (srcIndex + 1 >= srcLength)
        {
            frequencies.push_back(sample.pitchDeltas[srcIndex]);
        }
        else
        {
            frequencies.push_back((1 - srcWeight) * sample.pitchDeltas[srcIndex] + srcWeight * sample.pitchDeltas[srcIndex + 1]);
        }
        float amplitude = 0;
        for (int j = 0; j < 256; j++) {
            if (abs(sample.waveform[i * 256 + j]) > amplitude) {
                amplitude = abs(sample.waveform[i * 256 + j]);
            }
        }
        amplitudes.push_back(amplitude);
    }
}

std::map<std::string, int> parseFlagString(std::string flagString) {
    std::string supportedFlags[] =
    {
        "lovl",
        "loff",
        "pstb",
        "std",
        "bre",
        "int",
        "subh",
        "P",
        "dyn",
        "bri",
        "rgh",
        "grwl",
        "t",
        "g",
    };
    std::map<std::string, int> flags;
    bool warning = false;
    while (flagString.length() > 0) //iteratively remove the first flag from the string until it is empty
    {
        for (int i = 0; i <= 14; i++) //iterate through all supported flags
        {
            if (i == 14) //the beginning of the flag string does not match any supported flag. Discard the first symbol and try again.
            {
                flagString = flagString.substr(1, flagString.length() - 1);
                if (!warning)
                {
                    std::cout << "Warning: Unsupported flag(s) found. Other flags may be misinterpreted." << std::endl;
                    warning = true;
                }
                break;
            }
            if (flagString.find(supportedFlags[i]) == 0) //the beginning of the flag string matches a supported flag
            {
                for (size_t j = supportedFlags[i].length(); j <= flagString.length(); j++) //find the end of the flag value
                {
                    if (j == flagString.length() || (!isdigit(flagString[j]) && flagString[j] != '-')) //the end of the flag value is reached when a non-digit character other than the minus sign is found
                    {
                        flags[supportedFlags[i]] = std::stoi(flagString.substr(supportedFlags[i].length(), j - supportedFlags[i].length())); //store the flag value in the map
                        flagString = flagString.substr(j, flagString.length() - j);
                        break;
                    }
                }
                break;
            }
        }
    }
    return flags;
}

int noteToMidiPitch(std::string note) {
    std::string noteStr = "";
    std::string octaveStr = "";
    for (int i = 0; i < note.length(); i++) {
        if (isdigit(note[i])) {
            noteStr = note.substr(0, i);
            octaveStr = note.substr(i, note.length());
            break;
        }
    }
    int octave = std::stoi(octaveStr);
    int halftone = 0;
    if (noteStr.length() > 1) {
        switch (noteStr[1]) {
        case '#':
            halftone = 1;
            break;
        case 'b':
            halftone = -1;
            break;
        default:
            halftone = 0;
            break;
        }
    }
    switch (noteStr[0]) {
    case 'C':
        return 12 * octave + halftone;
    case 'D':
        return 12 * octave + 2 + halftone;
    case 'E':
        return 12 * octave + 4 + halftone;
    case 'F':
        return 12 * octave + 5 + halftone;
    case 'G':
        return 12 * octave + 7 + halftone;
    case 'A':
        return 12 * octave + 9 + halftone;
    case 'B':
        return 12 * octave + 11 + halftone;
    default:
        return 0;
    }
}

//converts a MIDI pitch value to an ESPER wavelength format pitch value
float midiPitchToEsperPitch(float pitch, engineCfg config)
{
    return (float)config.sampleRate / (440 * pow(2, (pitch - 69 + 12) / 12));
}

// Creates a cSampleCfg struct from an engineCfg object, and an ini config file
cSampleCfg createCSampleCfg(int numSamples, engineCfg cfg)
{
    cSampleCfg sampleCfg;
    sampleCfg.length = numSamples;
    sampleCfg.batches = numSamples / cfg.batchSize;
    sampleCfg.pitchLength = sampleCfg.batches;
    sampleCfg.pitch = 300;
    sampleCfg.isVoiced = 1;
    sampleCfg.isPlosive = 0;
    sampleCfg.useVariance = 1;
    sampleCfg.expectedPitch = 300.;
    sampleCfg.expectedPitch = 0;
    sampleCfg.tempWidth = 15;
    return sampleCfg;
}

// Creates a cSample struct from a waveform, its length, engineCfg object, and an ini config file
cSample createCSample(float* wave, int numSamples, engineCfg cfg)
{
    cSampleCfg sampleCfg = createCSampleCfg(numSamples, cfg);
    cSample sample;
    sample.waveform = wave;
    sample.pitchDeltas = (int*)malloc(sampleCfg.batches * sizeof(int));
    sample.pitchMarkers = (int*)malloc(sampleCfg.length * sizeof(int));
    sample.pitchMarkerValidity = (char*)malloc(sampleCfg.length * sizeof(char));
    sample.specharm = (float*)malloc(sampleCfg.batches * cfg.frameSize * sizeof(float));
    sample.avgSpecharm = (float*)malloc((cfg.halfHarmonics + cfg.halfTripleBatchSize + 1) * sizeof(float));
    sample.config = sampleCfg;
    return sample;
}

std::vector<int> toVector(int* ptr, std::size_t length) {
    if (!ptr) return {}; // handle null pointer just in case
    return std::vector<int>(ptr, ptr + length);
}

float* cloneFloatArray(float* source, std::size_t length) {
    if (!source) return nullptr;

    float* newArray = new float[length];
    std::memcpy(newArray, source, length * sizeof(float));
    return newArray;
}

HL_PRIM varray* HL_NAME(esper_utau)(varray* _samples, int numSamples, vstring* _note, vstring* _flags, int offset, int targetLength, int consonant, int cutoff, int volume, float tempo, varray* _pitchBend) {
    float* samples = cloneFloatArray(hl_aptr(_samples, float));
    char* note = hl_to_utf8(_note->bytes);
    char* flags = hl_to_utf8(_flags->bytes);
    int* pitchBend = hl_aptr(_pitchBend, int);

    resamplerArgs args;
    args.pitch = noteToMidiPitch(note);
    args.velocity = 100;
    args.flags = parseFlagString(flags);
    args.offset = offset;
    args.length = targetLength;
    args.consonant = consonant;
    args.cutoff = cutoff;
    args.volume = volume;
    args.modulation = 0;
    args.tempo = tempo;
    args.pitchBend = toVector(pitchBend, targetLength);

    //create sample object
    cSample sample;

    //load into sample object
    sample = createCSample(samples, numSamples, cfg);

    double avg_frq;
    std::vector<double> frequencies;
    std::vector<double> amplitudes;
    pitchCalcFallback(&sample, cfg);
    sample.pitchMarkers = (int*)realloc(sample.pitchMarkers, sample.config.markerLength * sizeof(int));
    getFrqFromSample(sample, frequencies, amplitudes, cfg);

    //perform spectral analysis
    specCalc(sample, cfg);


    //analysis complete, now perform resampling

    //convert milliseconds to ESPER frames
    args.length *= (float)cfg.sampleRate / (float)cfg.batchSize / 1000.f;
    args.consonant *= (float)cfg.sampleRate / (float)cfg.batchSize / 1000.f;
    args.offset *= (float)cfg.sampleRate / (float)cfg.batchSize / 1000.f;
    args.cutoff *= (float)cfg.sampleRate / (float)cfg.batchSize / 1000.f;

    //handle negative cutoff values
    if (args.cutoff < 0)
        args.cutoff *= -1;
    else
        args.cutoff = sample.config.batches - args.offset - args.cutoff;

    //read resampling flags
    float loopOffset = 0.f;
    if (args.flags.find("loff") != args.flags.end())
        loopOffset = (float)args.flags["loff"] / 100.f;
    args.cutoff -= args.consonant;
    loopOffset *= args.cutoff / 4.f;
    args.cutoff -= 2. * loopOffset;
    args.consonant += loopOffset;
    if (args.cutoff < 1.)
    {
        args.consonant -= 1. - args.cutoff;
        args.cutoff = 1.;
    }
    int esperLength = args.length;
    if (esperLength <= (int)args.consonant + 1)
        esperLength = (int)args.consonant + 2;
    args.length = esperLength - (int)args.consonant;

    //create arrays for curve parameters given as flags
    float* steadinessArr = (float*)malloc(esperLength * sizeof(float));
    float* breathinessArr = (float*)malloc(esperLength * sizeof(float));
    float* formantShiftArr = (float*)malloc(esperLength * sizeof(float));
    float steadiness = 0;
    float breathiness = 0;
    float formantShift = 0;
    if (args.flags.find("std") != args.flags.end())
        steadiness = (float)args.flags["std"] / 100.f;
    if (args.flags.find("bre") != args.flags.end())
        breathiness = (float)args.flags["bre"] / 101.f;
    if (args.flags.find("int") != args.flags.end())
        formantShift = (float)args.flags["int"] / 200.f;
    for (int i = 0; i < esperLength; i++)
    {
        steadinessArr[i] = steadiness;
        breathinessArr[i] = breathiness;
        formantShiftArr[i] = formantShift;
    }

    //create generic timing object
    segmentTiming timings;
    timings.start1 = 0;
    timings.start2 = 0;
    timings.start3 = 0;
    timings.end1 = args.length;
    timings.end2 = args.length;
    timings.end3 = args.length;
    timings.windowStart = 0;
    timings.windowEnd = args.length;
    timings.offset = 0;

    //resample specharm
    float* resampledSpecharm = (float*)malloc(esperLength * cfg.frameSize * sizeof(float));

    //copy consonant part wwithout resampling
    memcpy(resampledSpecharm, sample.specharm + (int)(args.offset) * cfg.frameSize, (int)(args.consonant) * cfg.frameSize * sizeof(float));
    for (int i = 0; i < (int)(args.consonant); i++)
    {
        for (unsigned int j = 0; j < cfg.halfHarmonics; j++)
        {
            resampledSpecharm[i * cfg.frameSize + j] += sample.avgSpecharm[j];
        }
        for (unsigned int j = cfg.halfHarmonics; j < cfg.halfHarmonics + cfg.halfTripleBatchSize + 1; j++)
        {
            resampledSpecharm[i * cfg.frameSize + cfg.halfHarmonics + j] += sample.avgSpecharm[j];
        }
    }

    //calculate correct average of vowel part for resampling
    float* effAvgSpecharm = (float*)malloc((cfg.halfHarmonics + cfg.halfTripleBatchSize + 1) * sizeof(float));
    for (int i = 0; i < cfg.halfHarmonics + cfg.halfTripleBatchSize + 1; i++)
    {
        effAvgSpecharm[i] = 0.;
    }
    float* effSpecharm = (float*)malloc((int)(args.cutoff) * cfg.frameSize * sizeof(float));
    for (int i = 0; i < (int)(args.cutoff); i++)
    {
        for (unsigned int j = 0; j < cfg.halfHarmonics; j++)
        {
            effSpecharm[i * cfg.frameSize + j] = sample.specharm[((int)(args.offset + args.consonant) + i) * cfg.frameSize + j] + sample.avgSpecharm[j];
            if (i < args.length)
            {
                effAvgSpecharm[j] += effSpecharm[i * cfg.frameSize + j];
            }
        }
        for (unsigned int j = 0; j < cfg.halfHarmonics; j++)
        {
            effSpecharm[i * cfg.frameSize + cfg.halfHarmonics + j] = sample.specharm[((int)(args.offset + args.consonant) + i) * cfg.frameSize + cfg.halfHarmonics + j];
        }
        for (unsigned int j = 0; j < cfg.halfTripleBatchSize + 1; j++)
        {
            effSpecharm[i * cfg.frameSize + 2 * cfg.halfHarmonics + j] = sample.specharm[((int)(args.offset + args.consonant) + i) * cfg.frameSize + 2 * cfg.halfHarmonics + j] + sample.avgSpecharm[cfg.halfHarmonics + j];
            if (i < args.length)
            {
                effAvgSpecharm[cfg.halfHarmonics + j] += effSpecharm[i * cfg.frameSize + 2 * cfg.halfHarmonics + j];
            }
        }
    }

    for (int i = 0; i < cfg.halfHarmonics + cfg.halfTripleBatchSize + 1; i++)
    {
        effAvgSpecharm[i] /= (int)(args.cutoff);
    }

    for (int i = 0; i < (int)(args.cutoff); i++)
    {
        for (unsigned int j = 0; j < cfg.halfHarmonics; j++)
        {
            effSpecharm[i * cfg.frameSize + j] -= effAvgSpecharm[j];
        }
        for (unsigned int j = 0; j < cfg.halfTripleBatchSize + 1; j++)
        {
            effSpecharm[i * cfg.frameSize + 2 * cfg.halfHarmonics + j] -= effAvgSpecharm[cfg.halfHarmonics + j];
        }
    }

    //loop overlap flag
    float loopOverlap = 0.5;
    if (args.flags.find("lovl") != args.flags.end())
    {
        loopOverlap = (float)args.flags["lovl"] / 101.f;
    }

    //resample vowel part
    resampleSpecharm(effAvgSpecharm, effSpecharm, (int)args.cutoff, steadinessArr, loopOverlap, 0, 1, resampledSpecharm + (int)(args.consonant) * cfg.frameSize, timings, cfg);

    //resample pitch
    for (int i = sample.config.pitchLength; i < sample.config.batches; i++)
    {
        sample.pitchDeltas[i] = sample.pitchDeltas[sample.config.pitchLength - 1];
    }
    float meanPitch = 0;
    for (int i = (int)args.offset; i < (int)args.offset + (int)args.consonant + (int)args.cutoff; i++)
    {
        meanPitch += sample.pitchDeltas[i];
    }
    meanPitch /= (int)args.consonant + (int)args.cutoff;
    float* resampledPitch = (float*)malloc(esperLength * sizeof(float));
    for (int i = 0; i < (int)(args.consonant); i++)
    {
        resampledPitch[i] = (float)(sample.pitchDeltas[(int)(args.offset) + i] - meanPitch);
    }
    resamplePitch(sample.pitchDeltas + (int)((args.offset) + args.consonant), (int)args.cutoff, meanPitch, loopOverlap, 0, 1, resampledPitch + (int)(args.consonant), args.length, timings);

    //modify pitch with stability flag
    if (args.flags.find("pstb") != args.flags.end())
    {
        if (args.flags["pstb"] > 0)
        {
            for (int i = 0; i < esperLength; i++)
            {
                resampledPitch[i] *= 1.f - args.flags["pstb"] / 100.f;
            }
        }
    }

    //derive source, target and modified target pitch arrays for pitch shifting
    //modified target pitch array is used by the pitch shift function, target pitch array is used for rendering
    float* srcPitch = (float*)malloc(esperLength * sizeof(float));
    for (int i = 0; i < (int)(esperLength); i++)
    {
        srcPitch[i] = resampledPitch[i] + meanPitch;
    }
    float* tgtPitch = (float*)malloc(esperLength * sizeof(float));
    float* tgtPitchMod = (float*)malloc(esperLength * sizeof(float));
    float pitchDeviation = 0;
    float timeMultiplier = 1.6 * args.tempo * cfg.batchSize / cfg.sampleRate;
    for (int i = 0; i < (int)(esperLength); i++)
    {
        float pitchBendPos = (float)i * timeMultiplier;
        int pitchBendIndex = (int)pitchBendPos;
        float pitchBendWeight = pitchBendPos - pitchBendIndex;
        float pitchBend;
        if (pitchBendIndex >= args.pitchBend.size() - 1)
        {
            pitchBend = args.pitchBend[args.pitchBend.size() - 1];
        }
        else
        {
            pitchBend = args.pitchBend[pitchBendIndex] * (1 - pitchBendWeight) + args.pitchBend[pitchBendIndex + 1] * pitchBendWeight;
        }
        if (args.flags.find("t") != args.flags.end())
        {
            tgtPitch[i] = resampledPitch[i] + midiPitchToEsperPitch((float)args.pitch, cfg) * powf(2, pitchBend / 1200) * powf(2, (float)args.flags["t"] / 100);
        }
        else
        {
            tgtPitch[i] = resampledPitch[i] + midiPitchToEsperPitch((float)args.pitch, cfg) * powf(2, pitchBend / 1200);
        }
        if (args.flags.find("pstb") != args.flags.end())
        {
            if (args.flags["pstb"] < 0)
            {
                float randNum = 0;
                for (int j = 0; j < 12; j++)
                {
                    randNum += (double)rand() / (double)RAND_MAX - 0.5;
                }
                pitchDeviation += randNum;
                pitchDeviation /= 1.1;
                tgtPitch[i] -= pitchDeviation * (float)args.flags["pstb"] / 100.;
            }
        }
        if (tgtPitch[i] < 10.)
        {
            tgtPitch[i] = 10.;
        }
        tgtPitchMod[i] = tgtPitch[i];
        if (args.flags.find("gen") != args.flags.end())
        {
            float flag = (float)args.flags["gen"] / 100.;
            if (flag > 0)
            {
                tgtPitchMod[i] *= 1. + flag;
            }
            else
            {
                tgtPitchMod[i] /= 1. - flag;
            }
        }
    }

    //apply pitch shift
    pitchShift(resampledSpecharm, srcPitch, tgtPitchMod, formantShiftArr, breathinessArr, esperLength, cfg);

    //apply other effects
    float subharmonics = 1.f;
    if (args.flags.find("subh") != args.flags.end())
    {
        subharmonics = powf(1.f + (float)args.flags["subh"] / 100.f, 2.f);
    }
    for (int i = 0; i < esperLength; i++)
    {
        resampledSpecharm[i * cfg.frameSize] *= subharmonics;
    }
    float* paramArr = (float*)malloc(esperLength * sizeof(float));
    if (args.flags.find("bre") != args.flags.end())
    {
        applyBreathiness(resampledSpecharm, breathinessArr, esperLength, cfg);
    }
    if (args.flags.find("bri") != args.flags.end())
    {
        for (int i = 0; i < esperLength; i++)
        {
            paramArr[i] = (float)args.flags["bri"] / 100.f;
        }
        applyBrightness(resampledSpecharm, paramArr, esperLength, cfg);
    }
    if (args.flags.find("dyn") != args.flags.end())
    {
        for (int i = 0; i < esperLength; i++)
        {
            paramArr[i] = (float)args.flags["dyn"] / 100.f;
        }
        applyDynamics(resampledSpecharm, paramArr, tgtPitch, esperLength, cfg);
    }
    float phase = 0;
    if (args.flags.find("grwl") != args.flags.end())
    {
        for (int i = 0; i < esperLength; i++)
        {
            paramArr[i] = (float)args.flags["grwl"] / 100.f;
        }
        applyGrowl(resampledSpecharm, paramArr, &phase, esperLength, cfg);
    }
    if (args.flags.find("rgh") != args.flags.end())
    {
        for (int i = 0; i < esperLength; i++)
        {
            paramArr[i] = (float)args.flags["rgh"] / 100.f;
        }
        applyRoughness(resampledSpecharm, paramArr, esperLength, cfg);
    }

    if (args.flags.find("p") != args.flags.end())
    {
        float max = 0.f;
        for (int i = 0; i < esperLength; i++)
        {
            for (int j = 0; j < cfg.halfHarmonics; j++)
            {
                if (resampledSpecharm[i * cfg.frameSize + j] > max)
                {
                    max = resampledSpecharm[i * cfg.frameSize + j];
                }
            }
            for (int j = cfg.nHarmonics + 2; j < cfg.frameSize; j++)
            {
                if (resampledSpecharm[i * cfg.frameSize + j] > max)
                {
                    max = resampledSpecharm[i * cfg.frameSize + j];
                }
            }
        }
        max *= 1.f + 100.f * powf(1.f - (float)args.flags["p"] / 100, 4.f) * 2.f;
        for (int i = 0; i < esperLength; i++)
        {
            float localMax = 0.f;
            for (int j = 0; j < cfg.halfHarmonics; j++)
            {
                if (resampledSpecharm[i * cfg.frameSize + j] > localMax)
                {
                    localMax = resampledSpecharm[i * cfg.frameSize + j];
                }
            }
            for (int j = cfg.nHarmonics + 2; j < cfg.frameSize; j++)
            {
                if (resampledSpecharm[i * cfg.frameSize + j] > localMax)
                {
                    localMax = resampledSpecharm[i * cfg.frameSize + j];
                }
            }
            for (int j = 0; j < cfg.halfHarmonics; j++)
            {
                resampledSpecharm[i * cfg.frameSize + j] *= sin(3.14159 * localMax / max) * max;
            }
            for (int j = cfg.nHarmonics + 2; j < cfg.frameSize; j++)
            {
                resampledSpecharm[i * cfg.frameSize + j] *= sin(3.14159 * localMax / max) * max;
            }
        }
    }

    //final rendering
    float* resampledWave = (float*)malloc(esperLength * cfg.batchSize * sizeof(float));
    for (int i = 0; i < esperLength * cfg.batchSize; i++)
    {
        resampledWave[i] = 0;
    }
    phase = 0;
    render(resampledSpecharm, tgtPitch, &phase, resampledWave, esperLength, cfg);
}
DEFINE_PRIM(_VOID, esper_utau, _ARR _ARR _I32);