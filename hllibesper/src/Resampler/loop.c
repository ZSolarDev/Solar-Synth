//Copyright 2023 Johannes Klatt

//This file is part of libESPER.
//libESPER is free software: you can redistribute it and /or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or any later version.
//libESPER is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//You should have received a copy of the GNU General Public License along with Nova - Vox.If not, see <https://www.gnu.org/licenses/>.

#include "Resampler/loop.h"

#include <malloc.h>
#include "util.h"
#include "interpolation.h"

//loops the voiced part of an input signal to match a target length. The spacing parameter determines the overlap between the windows.
void loopSamplerVoiced(float* input, int length, float* output, int targetLength, float spacing, engineCfg config)
{
    int effSpacing = ceildiv(spacing * length,  2);
    int requiredInstances = targetLength / (length - effSpacing);
    int lastWin = targetLength - requiredInstances * (length - effSpacing);
    if (targetLength <= length)
    {
        //one instance is enough to cover the entire length.
        //Just copy the data instead of looping.
        for (int i = 0; i < targetLength; i++)
        {
			for (int j = 0; j < config.nHarmonics + 2; j++)
                *(output + i * config.frameSize + j) = *(input + i * config.frameSize + j);
        }
    }
    else
    {
        float* buffer = (float*) malloc((length - effSpacing) * (config.nHarmonics + 2) * sizeof(float)); //allocate buffer
        //add first window to output and fill buffer
        for (int i = 0; i < (length - effSpacing); i++)
        {
			for (int j = 0; j < config.nHarmonics + 2; j++)
			{
				*(output + i * config.frameSize + j) = *(input + i * config.frameSize + j);
				*(buffer + i * (config.nHarmonics + 2) + j) = *(input + i * config.frameSize + j);
			}
        }
        //modify start of buffer to include transition
        for (int i = 0; i < effSpacing; i++)
        {
            for (int j = 0; j < config.halfHarmonics; j++)
            {
                *(buffer + i * (config.nHarmonics + 2) + j) *= (float)(i + 1) / (float)(effSpacing + 1);
                *(buffer + i * (config.nHarmonics + 2) + j) += *(input + (length - effSpacing + i) * config.frameSize + j) * (1. - (float)(i + 1) / (float)(effSpacing + 1));
            }
            phaseInterp_inplace(buffer + i * (config.nHarmonics + 2) + config.halfHarmonics, input + (length - effSpacing + i) * config.frameSize + config.halfHarmonics, config.halfHarmonics, 1. - (float)(i + 1) / (float)(effSpacing + 1));
        }
        //add mid windows from buffer to output
        #pragma omp parallel for
        for (int i = 1; i < requiredInstances; i++)
        {
            for (int j = 0; j < (length - effSpacing); j++)
            {
				for (int k = 0; k < config.nHarmonics + 2; k++)
					*(output + (i * (length - effSpacing) + j) * config.frameSize + k) = *(buffer + j * (config.nHarmonics + 2) + k);
            }
        }
        //add final window, which has a length below the buffer size. Use buffer data if the window is still long enough to require a transition, otherwise fall back to input data
        if (lastWin >= effSpacing)
        {
            for (int i = 0; i < lastWin; i++)
            {
                for (int j = 0; j < config.nHarmonics + 2; j++)
                {
					*(output + (requiredInstances * (length - effSpacing) + i) * config.frameSize + j) = *(buffer + i * (config.nHarmonics + 2) + j);
                }
            }
        }
        else
        {
            for (int i = 0; i < lastWin; i++)
            {
				for (int j = 0; j < config.nHarmonics + 2; j++)
				{
					*(output + (requiredInstances * (length - effSpacing) + i) * config.frameSize + j) = *(input + (length - effSpacing + i) * config.frameSize + j);
				}
            }
        }
        free(buffer);
    }
}

//stretches the unvoiced part of an input signal to match a target length.
//Since the unvoiced part is assumed to be spectral noise, a random phase is assigned to each fourier component in each frame.
//For spectral noise, this results in no audible changes, but other types of audio are NOT preserved.
void stretchSamplerUnvoiced(float* input, int length, float* output, int targetLength, engineCfg config)
{
    float* idxs = (float*)malloc(length * sizeof(float));
    for (int i = 0; i < length; i++)
    {
        *(idxs + i) = i;
    }
    float* positions = (float*)malloc(targetLength * sizeof(float));
    float rate = (float)length / (float)targetLength;
    for (int i = 0; i < targetLength; i++)
    {
        *(positions + i) = i * rate;
    }
    float* source = (float*)malloc(length * sizeof(float));
    for (int i = 0; i < config.halfTripleBatchSize + 1; i++)
    {
        for (int j = 0; j < length; j++)
        {
            *(source + j) = *(input + j * config.frameSize + config.nHarmonics + 2 + i);
        }
        float* target = extrap(idxs, source, positions, length, targetLength);
        for (int j = 0; j < targetLength; j++)
        {
            *(output + j * config.frameSize + config.nHarmonics + 2 + i) = *(target + j);
        }
        free(target);
    }
    free(idxs);
    free(positions);
    free(source);
}

//adjusts the length of an input signal to match a target length by looping the voiced part and stretching the unvoiced part.
void loopSamplerSpecharm(float* input, int length, float* output, int targetLength, float spacing, engineCfg config)
{
	for (int i = 0; i < targetLength * config.frameSize; i++)
	{
		*(output + i) = 0.;
	}
	loopSamplerVoiced(input, length, output, targetLength, spacing, config);
	stretchSamplerUnvoiced(input, length, output, targetLength, config);
}

//loops pitch data with configurable overlap between instances
void loopSamplerPitch(int* input, int length, float* output, int targetLength, float spacing)
{
    int effSpacing = ceildiv(spacing * length,  2);
    int requiredInstances = targetLength / (length - effSpacing);
    int lastWin = targetLength - requiredInstances * (length - effSpacing);
    if (targetLength <= length)
    {
        //only one instance required
        for (int i = 0; i < targetLength; i++)
        {
            *(output + i) = (float)*(input + i);
        }
    }
    else
    {
        float* buffer = (float*) malloc((length - effSpacing) * sizeof(float)); //allocate buffer
        //add first window to output and fill buffer
        for (int i = 0; i < (length - effSpacing); i++)
        {
            *(output + i) = (float)*(input + i);
            *(buffer + i) = (float)*(input + i);
        }
        //modify start of buffer to include transition
        for (int i = 0; i < effSpacing; i++)
        {
            *(buffer + i) *= (float)(i) / (float)(effSpacing);
            *(buffer + i) += (float)*(input + length - effSpacing + i) * (1. - ((float)(i) / (float)(effSpacing)));
        }
        //add mid windows from buffer to output
        #pragma omp parallel for
        for (int i = 1; i < requiredInstances; i++)
        {
            for (int j = 0; j < (length - effSpacing); j++)
            {
                *(output + i * (length - effSpacing) + j) = *(buffer + j);
            }
        }
        //add final window, which has a length below the buffer size. Use buffer data if the window is still long enough to require a transition, otherwise fall back to input data
        if (lastWin > effSpacing)
        {
            for (int i = 0; i < lastWin; i++)
            {
                *(output + requiredInstances * (length - effSpacing) + i) = *(buffer + i);
            }
        }
        else
        {
            for (int i = 0; i < lastWin; i++)
            {
                *(output + requiredInstances * (length - effSpacing) + i) = (float)*(input + length - effSpacing + i);
            }
        }
        free(buffer);
    }
}
