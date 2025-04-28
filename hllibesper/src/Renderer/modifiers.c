// Copyright 2024 Johannes Klatt
// This file is part of libESPER.
// libESPER is free software: you can redistribute it and /or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or any later version.
// libESPER is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
// You should have received a copy of the GNU General Public License along with Nova - Vox. If not, see <https://www.gnu.org/licenses/>.

#include "Renderer/modifiers.h"

#include <malloc.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include "util.h"
#include "fft.h"
#include "interpolation.h"
#include LIBESPER_FFTW_INCLUDE_PATH

void LIBESPER_CDECL applyBreathiness(float* specharm, float* breathiness, int length, engineCfg config) {
    for (int i = 0; i < length; i++) {
        float compensation = 0.;
        float divisor = 1.;
        for (int j = 0; j < config.halfHarmonics; j++) {
            compensation += powf(*(specharm + i * config.frameSize + j), 2.);
        }
        for (int j = 0; j < config.halfTripleBatchSize + 1; j++) {
            divisor += powf(*(specharm + i * config.frameSize + config.nHarmonics + 2 + j), 2.);
        }
        compensation *= config.breCompPremul / divisor;
        compensation *= (config.halfTripleBatchSize + 1) / config.halfHarmonics;
        float breathinessVoiced;
        float breathinessUnvoiced;
        if (*(breathiness + i) >= 0.) {
            breathinessVoiced = 1. - *(breathiness + i);
            breathinessUnvoiced = 1. + *(breathiness + i) * compensation;
        }
        else {
            breathinessVoiced = 1.;
            breathinessUnvoiced = 1. + *(breathiness + i);
        }
        for (int j = 0; j < config.halfHarmonics; j++) {
            *(specharm + i * config.frameSize + j) *= breathinessVoiced;
        }
        for (int j = config.nHarmonics + 2; j < config.frameSize; j++) {
            *(specharm + i * config.frameSize + j) *= breathinessUnvoiced;
        }
    }
}

void LIBESPER_CDECL pitchShift(float* specharm, float* srcPitch, float* tgtPitch, float* formantShift, float* breathiness, int length, engineCfg config) {
    float* tgtSpace = (float*)malloc(config.halfHarmonics * sizeof(float));
    float* srcSpace = (float*)malloc(sizeof(float));
    float* srcVals = (float*)malloc(sizeof(float));
    int maxSrcSize = 1;
    for (int i = 0; i < length; i++) {
        float effSrcPitch = (float)config.tripleBatchSize / *(srcPitch + i);
        float effTgtPitch = (float)config.tripleBatchSize / *(tgtPitch + i);
        float srcAmplitude = 1.;
        float tgtAmplitude = 1.;
        int reprSwitch = config.halfHarmonics * effSrcPitch;
        if (reprSwitch > config.halfTripleBatchSize) {
            reprSwitch = config.halfTripleBatchSize + 1;
        }
        int srcSize = config.halfHarmonics + config.halfTripleBatchSize + 1 - reprSwitch;
        if (srcSize < (int)config.halfHarmonics) {
            srcSize = config.halfHarmonics;
        }
        if (srcSize > maxSrcSize) {
            srcSpace = (float*)realloc(srcSpace, srcSize * sizeof(float));
            srcVals = (float*)realloc(srcVals, srcSize * sizeof(float));
            maxSrcSize = srcSize;
        }

        for (int j = 0; j < config.halfHarmonics; j++) {
            *(srcSpace + j) = j * effSrcPitch;
            if (*(srcSpace + j) > config.halfTripleBatchSize) {
                *(srcSpace + j) = config.halfTripleBatchSize + (j + 1.) / (config.halfHarmonics + 1);
            }
            *(tgtSpace + j) = j * effTgtPitch;
            if (*(tgtSpace + j) > config.halfTripleBatchSize) {
                *(tgtSpace + j) = config.halfTripleBatchSize;
            }
            *(srcVals + j) = *(specharm + i * config.frameSize + j);
            srcAmplitude += *(srcVals + j);
        }
        for (int j = 0; j < config.halfTripleBatchSize + 1 - reprSwitch; j++) {
            *(srcSpace + config.halfHarmonics + j) = reprSwitch + j;
            *(srcVals + config.halfHarmonics + j) = *(specharm + i * config.frameSize + config.nHarmonics + 2 + reprSwitch + j);
        }
        float* tgtVals = interp(srcSpace, srcVals, tgtSpace, srcSize, config.halfHarmonics);
        for (int j = 0; j < config.halfHarmonics; j++) {
            *(specharm + i * config.frameSize + j) = *(tgtVals + j);
            tgtAmplitude += *(tgtVals + j);
        }
        free(tgtVals);
        for (int j = 0; j < config.halfHarmonics; j++) {
            *(specharm + i * config.frameSize + j) *= sqrtf(srcAmplitude / tgtAmplitude);
        }
    }
    free(srcSpace);
    free(srcVals);
    free(tgtSpace);
}

void LIBESPER_CDECL applyDynamics(float* specharm, float* dynamics, float* pitch, int length, engineCfg config) {
    for (int i = 0; i < length; i++) {
        float thresholdA = 500 * powf((float)config.tripleBatchSize, 2.) / (float)config.sampleRate / *(pitch + i);
        float thresholdB = 2. * thresholdA;
        for (int j = 0; j < config.halfHarmonics; j++) {
            if (j < thresholdA) {
                *(specharm + i * config.frameSize + j) *= 1. + 0.25 * *(dynamics + i);
            }
            else if (j < thresholdB) {
                *(specharm + i * config.frameSize + j) *= 1. + 0.25 * *(dynamics + i) * (j - thresholdA) / (thresholdB - thresholdA);
            }
        }

        thresholdA = 500 * config.tripleBatchSize / config.sampleRate;
        thresholdB = 4. * thresholdA;
        float thresholdC = 5. * thresholdB;
        for (int j = 0; j < config.halfTripleBatchSize; j++) {
            if (j < thresholdA) {
                continue;
            }
            else if (j < thresholdB) {
                *(specharm + i * config.frameSize + config.nHarmonics + 2 + j) *= 1. - *(dynamics + i) * (j - thresholdA) / (thresholdB - thresholdA);
            }
            else if (j < thresholdC) {
                *(specharm + i * config.frameSize + config.nHarmonics + 2 + j) *= 1. - *(dynamics + i) * (thresholdC - j) / (thresholdC - thresholdB);
            }
            if (*(dynamics + i) < 0.) {
                *(specharm + i * config.frameSize + config.nHarmonics + 2 + j) *= 1. + 0.5 * *(dynamics + i);
            }
        }
    }
}

void LIBESPER_CDECL applyBrightness(float* specharm, float* brightness, int length, engineCfg config) {
    for (int i = 0; i < length; i++) {
        float exponent = 1. - 0.5 * *(brightness + i);
        float reference = 0.;
        for (int j = 0; j < config.halfHarmonics; j++) {
            if (*(specharm + i * config.frameSize + j) > reference) {
                reference = *(specharm + i * config.frameSize + j);
            }
        }
        reference *= 0.9;
        for (int j = 0; j < config.halfHarmonics; j++) {
            *(specharm + i * config.frameSize + j) = powf(*(specharm + i * config.frameSize + j) / reference, exponent) * reference;
        }

        reference = 0.;
        for (int j = 0; j < config.halfTripleBatchSize; j++) {
            if (*(specharm + i * config.frameSize + config.nHarmonics + 2 + j) > reference) {
                reference = *(specharm + i * config.frameSize + config.nHarmonics + 2 + j);
            }
        }
        reference *= 0.9;
        for (int j = 0; j < config.halfTripleBatchSize; j++) {
            *(specharm + i * config.frameSize + config.nHarmonics + 2 + j) = powf(*(specharm + i * config.frameSize + config.nHarmonics + 2 + j) / reference, exponent) * reference;
        }

        if (*(brightness + i) > 0.) {
            for (int j = 0; j < config.halfHarmonics; j++) {
                *(specharm + i * config.frameSize + config.halfHarmonics + j) *= 1. - *(brightness + i);
            }
        }
    }
}

void LIBESPER_CDECL applyGrowl(float* specharm, float* growl, float* lfoPhase, int length, engineCfg config) {
    for (int i = 0; i < length; i++) {
        float phaseAdvance = 2. * 3.1415926535 / config.tickRate * 15.;
        *lfoPhase += phaseAdvance;
        if (*lfoPhase >= 2. * 3.1415926535) {
            *lfoPhase -= 2. * 3.1415926535;
        }
        float exponent = 2.f + (double)rand() / (double)RAND_MAX * 4.f;
        float lfo = 1. - powf(fabsf(sin(*lfoPhase)), exponent) * *(growl + i);
        for (int j = 0; j < config.halfHarmonics; j++) {
            *(specharm + i * config.frameSize + j) *= lfo;
        }
        for (int j = 0; j < config.halfTripleBatchSize; j++) {
            *(specharm + i * config.frameSize + config.nHarmonics + 2 + j) *= lfo;
        }
    }
}

void LIBESPER_CDECL applyRoughness(float* specharm, float* roughness, int length, engineCfg config) {
    for (int i = 0; i < length; i++) {
        for (int j = 0; j < config.halfHarmonics; j++) {
            *(specharm + i * config.frameSize + j) *= powf(1. - *(roughness + i) * 0.5, j);
        }
        for (int j = 0; j < config.halfTripleBatchSize; j++) {
            *(specharm + i * config.frameSize + config.nHarmonics + 2 + j) *= powf(1. - *(roughness + i) * 0.5, j);
        }
    }
}