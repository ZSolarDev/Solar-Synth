//Copyright 2023 Johannes Klatt

//This file is part of libESPER.
//libESPER is free software: you can redistribute it and /or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or any later version.
//libESPER is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//You should have received a copy of the GNU General Public License along with Nova - Vox.If not, see <https://www.gnu.org/licenses/>.

#include "Resampler/resampler.h"

#include <malloc.h>
#include <math.h>
#include "util.h"
#include "interpolation.h"
#include "Resampler/loop.h"

//resamples a specharm signal. This includes the following operations:
// - looping the specharm array (assumed to contain deviations from the average) according to the spacing parameter
// - scaling the specharm array according to the steadiness parameter
// - adding the scaled specharm to the average specharm
// - fading the result in and/or out if required according to the startCap and endCap parameters
void LIBESPER_CDECL resampleSpecharm(float* avgSpecharm, float* specharm, int length, float* steadiness, float spacing, int startCap, int endCap, float* output, segmentTiming timings, engineCfg config)
{
    float* buffer = (float*) malloc(timings.windowEnd * config.frameSize * sizeof(float));
    //loop specharm
    loopSamplerSpecharm(specharm, length, buffer, timings.windowEnd, spacing, config);
    //scale specharm according to steadiness setting and add it to average
    #pragma omp parallel for
    for (int i = 0; i < timings.windowEnd; i++)
    {
		float multiplier = 1. - *(steadiness + i);
        for (int j = 0; j < config.halfHarmonics; j++)
        {
            *(buffer + i * config.frameSize + j) *= multiplier;
            *(buffer + i * config.frameSize + j) += *(avgSpecharm + j);
			if (*(buffer + i * config.frameSize + j) < 0)
			{
				*(buffer + i * config.frameSize + j) = 0;
			}
        }
        for (int j = 2 * config.halfHarmonics; j < config.frameSize; j++)
        {
            *(buffer + i * config.frameSize + j) *= multiplier;
            *(buffer + i * config.frameSize + j) += *(avgSpecharm - config.halfHarmonics + j);//j start offset and subtraction result in addition of halfHarmonics when combined
            if (*(buffer + i * config.frameSize + j) < 0)
            {
                *(buffer + i * config.frameSize + j) = 0;
            }
        }
    }
    //fade in sample if required
    if (startCap != 0)
    {
        float factor = -log2f((float)(timings.start2 - timings.start1) / (float)(timings.start3 - timings.start1));
        for (int i = timings.windowStart; i < timings.windowStart + timings.start3 - timings.start1; i++)
        {
            for (int j = 0; j < config.halfHarmonics; j++)
            {
                *(buffer + i * config.frameSize + j) *= powf((float)(i - timings.windowStart + 1) / (float)(timings.start3 - timings.start1 + 1), factor);
            }
            for (int j = 2 * config.halfHarmonics; j < config.frameSize; j++)
            {
                *(buffer + i * config.frameSize + j) *= powf((float)(i - timings.windowStart + 1) / (float)(timings.start3 - timings.start1 + 1), factor);
            }
        }
    }
    //fade out sample if required
    if (endCap != 0)
    {
        float factor = -log2f((float)(timings.end3 - timings.end2) / (float)(timings.end3 - timings.end1));
        for (int i = timings.windowEnd + timings.end1 - timings.end3; i < timings.windowEnd; i++)
        {
            for (int j = 0; j < config.halfHarmonics; j++)
            {
                *(buffer + i * config.frameSize + j) *= powf(1. - ((float)(i - timings.windowEnd - timings.end1 + timings.end3 + 1) / (float)(timings.end3 - timings.end1 + 1)), factor);
            }
            for (int j = 2 * config.halfHarmonics; j < config.frameSize; j++)
            {
                *(buffer + i * config.frameSize + j) *= powf(1. - ((float)(i - timings.windowEnd - timings.end1 + timings.end3 + 1) / (float)(timings.end3 - timings.end1 + 1)), factor);
            }
        }
    }
    //fill output buffer
    #pragma omp parallel for
    for (int i = 0; i < (timings.windowEnd - timings.windowStart) * config.frameSize; i++)
    {
        *(output + i) = *(buffer + timings.windowStart * config.frameSize + i);
    }
    free(buffer);
}

//Resamples pitch data. This includes the following operations:
// - looping the pitchDeltas array according to the spacing parameter
// - subtracting the pitch parameter from the result, creating an array of pitch deviations
// - fading the result in and/or out if required according to the startCap and endCap parameters
void LIBESPER_CDECL resamplePitch(int* pitchDeltas, int length, float pitch, float spacing, int startCap, int endCap, float* output, int requiredSize, segmentTiming timings)
{
    //loop pitch
    loopSamplerPitch(pitchDeltas, length, output, requiredSize, spacing);
    //load data into output buffer
    #pragma omp parallel for
    for (int i = 0; i < requiredSize; i++)
    {
        *(output + i) -= pitch;
    }
    //fade in if required
    if (startCap == 0)
    {
        float factor = -log2f((float)(timings.start2 - timings.start1) / (float)(timings.start3 - timings.start1));
        for (int i = 0; i < timings.start3 - timings.start1; i++)
        {
            *(output + i) *= powf((float)(i + 1) / (float)(timings.start3 - timings.start1 + 1), factor);
        }
    }
    //fade out if required
    if (endCap == 0)
    {
        float factor = -log2f((float)(timings.end3 - timings.end2) / (float)(timings.end3 - timings.end1));
        for (int i = requiredSize - timings.end3 + timings.end1; i < requiredSize; i++)
        {
            *(output + i) *= powf(1. - ((float)(i - (requiredSize - timings.end3 + timings.end1) + 1) / (float)(timings.end3 - timings.end1 + 1)), factor);
        }
    }
}
