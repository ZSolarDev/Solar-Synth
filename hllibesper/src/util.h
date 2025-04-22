//Copyright 2023 - 2024 Johannes Klatt

//This file is part of libESPER.
//libESPER is free software: you can redistribute it and /or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or any later version.
//libESPER is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//You should have received a copy of the GNU General Public License along with Nova - Vox.If not, see <https://www.gnu.org/licenses/>.

#pragma once

#ifdef LIBESPER_BUILD
    #ifdef _WIN32
        #define LIBESPER_EXPORT __declspec(dllexport)
        #define LIBESPER_CDECL __cdecl
        #define LIBESPER_FFTW_INCLUDE_PATH "fftw3.h"
        #define LIBESPER_NFFT_INCLUDE_PATH "nfft3.h"
    #elif __GNUC__ >= 4
        #define LIBESPER_EXPORT __attribute__((visibility("default")))
        #define LIBESPER_CDECL
        #define LIBESPER_FFTW_INCLUDE_PATH "fftwf/src/fftwf/api/fftw3.h"
        #define LIBESPER_NFFT_INCLUDE_PATH "nfft/src/nfft/include/nfft3.h"
    #else
        #define LIBESPER_EXPORT
        #define LIBESPER_CDECL
        #define LIBESPER_FFTW_INCLUDE_PATH "fftwf/src/fftwf/api/fftw3.h"
        #define LIBESPER_NFFT_INCLUDE_PATH "nfft/src/nfft/include/nfft3.h"
    #endif
#else
    #ifdef _WIN32
        #define LIBESPER_EXPORT __declspec(dllimport)
        #define LIBESPER_CDECL __cdecl
        #define LIBESPER_FFTW_INCLUDE_PATH "fftw3.h"
        #define LIBESPER_NFFT_INCLUDE_PATH "nfft3.h"
    #else
        #define LIBESPER_EXPORT
        #define LIBESPER_CDECL
        #define LIBESPER_FFTW_INCLUDE_PATH "fftwf/src/fftwf/api/fftw3.h"
        #define LIBESPER_NFFT_INCLUDE_PATH "nfft/src/nfft/include/nfft3.h"
    #endif
#endif

#include LIBESPER_FFTW_INCLUDE_PATH

//struct holding parameters related to data batching and spectral filtering shared across the entire engine.
typedef struct
{
    unsigned int sampleRate;
    unsigned short tickRate;
    unsigned int batchSize;
    unsigned int tripleBatchSize;
    unsigned int halfTripleBatchSize; //expected to be exactly tripleBatchSize/2 without additional space for DC offset, since this is also used outside of rfft
    unsigned int nHarmonics;
    unsigned int halfHarmonics; //expected to be nHarmonics/2 + 1 (to account for DC offset after rfft)
    unsigned int frameSize; //expected to be nHarmonics + halfTripleBatchSize + 3 for joint harmonics + spectrum representation
    float breCompPremul;
}
engineCfg;

//struct holding all sample-specific information and settings required by ESPER for a single audio sample
typedef struct
{
    unsigned int length;
    unsigned int batches;
    unsigned int pitchLength;
	unsigned int markerLength;
    unsigned int pitch;
    int isVoiced;
    int isPlosive;
    int useVariance;
    float expectedPitch;
    float searchRange;
    unsigned short tempWidth;
}
cSampleCfg;

//struct holding an audio sample and its settings
typedef struct
{
    float* waveform;
    int* pitchDeltas;
	int* pitchMarkers;
	char* pitchMarkerValidity;
    float* specharm;
    float* avgSpecharm;
    cSampleCfg config;
}
cSample;

//struct containing all timing markers for a vocalSegment object. Used for resampling.
typedef struct
{
    unsigned int start1;
    unsigned int start2;
    unsigned int start3;
    unsigned int end1;
    unsigned int end2;
    unsigned int end3;
    unsigned int windowStart;
    unsigned int windowEnd;
    unsigned int offset;
}
segmentTiming;

//struct for a dynamic integer array, usable for arbitrary purposes
typedef struct
{
    int* content;
    unsigned int length;
    unsigned int maxlen;
}
dynIntArray;

void dynIntArray_init(dynIntArray* array);

void dynIntArray_dealloc(dynIntArray* array);

void dynIntArray_append(dynIntArray* array, int value);

int ceildiv(int numerator, int denominator);

unsigned int findIndex(int* markers, unsigned int markerLength, int position);

unsigned int findIndex_double(double* markers, unsigned int markerLength, int position);

int compare_uint(const void* a, const void* b);

unsigned int median(unsigned int* array, unsigned int length);

int compare_float(const void* a, const void* b);

float medianf(float* array, unsigned int length);

float cpxAbsf(fftwf_complex input);

double cpxAbsd(fftw_complex input);

float cpxArgf(fftwf_complex input);

double cpxArgd(fftw_complex input);

float* hannWindow(int length, float multiplier);

float random_normal(float mean, float stddev);

extern float pi;
