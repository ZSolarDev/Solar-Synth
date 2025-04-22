//Copyright 2024 Johannes Klatt

//This file is part of libESPER.
//libESPER is free software: you can redistribute it and /or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or any later version.
//libESPER is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//You should have received a copy of the GNU General Public License along with Nova - Vox.If not, see <https://www.gnu.org/licenses/>.

#include "Renderer/renderer.h"

#include <malloc.h>
#include <math.h>
#include <stdio.h>
#include "util.h"
#include "fft.h"
#include "interpolation.h"
#include LIBESPER_FFTW_INCLUDE_PATH
#include LIBESPER_NFFT_INCLUDE_PATH

//renders the unvoiced part of a specharm signal.
void LIBESPER_CDECL renderUnvoiced(float* specharm, float* target, int length, engineCfg config)
{
	fftwf_complex* cpxExcitation = (fftwf_complex*)malloc(length * (config.halfTripleBatchSize + 1) * sizeof(fftwf_complex));
	for (int i = 0; i < length; i++)
	{
		for (int j = 0; j < config.halfTripleBatchSize + 1; j++)
		{
			//The absolute values of the excitation follow Rayleigh distributions.
			//The values saved in the specharm array are the mean values of these distributions.
			//To correctly generate random complex vectors of magnitudes following this distribution, we need to convert from the mean of the Rayleigh distribution to its scale parameter.
			//This results in a division by sqrt(pi/2).
			float multiplier = *(specharm + i * config.frameSize + config.nHarmonics + 2 + j) / sqrt(pi/2.);
			(*(cpxExcitation + i * (config.halfTripleBatchSize + 1) + j))[0] = random_normal(0, multiplier);
			(*(cpxExcitation + i * (config.halfTripleBatchSize + 1) + j))[1] = random_normal(0, multiplier);
		}
	}
	istft_hann_inpl(cpxExcitation, length, length * config.batchSize, config, target);
	free(cpxExcitation);
}

//renders the voiced part of a specharm signal. The result is added to the existing content of the target array, rather than overwriting it.
void LIBESPER_CDECL renderVoiced(float* specharm, float* pitch, float* phase, float* target, int length, engineCfg config)
{
	float* frameSpace = (float*)malloc(length * sizeof(float));
	for (int i = 0; i < length; i++)
	{
		*(frameSpace + i) = (float)i;
	}
	float* waveSpace = (float*)malloc(length * config.batchSize * sizeof(float));
	for (int i = 0; i < length * config.batchSize; i++)
	{
		*(waveSpace + i) = ((float)i - 0.5) / (float)config.batchSize;
	}
	interp_caches harmInterpCaches = interp_setup(frameSpace, waveSpace, length, length * config.batchSize);
	float* wavePitch = extrap(frameSpace, pitch, waveSpace, length, length * config.batchSize);
	float* pitchOffsets = (float*)malloc(length * config.batchSize * sizeof(float));
	*pitchOffsets = 0.;
	for (int i = 0; i < length * config.batchSize - 1; i++)
	{
		*(pitchOffsets + i + 1) = fmodf(*(pitchOffsets + i) + 1. / *(wavePitch + i), 1.);
	}
	free(wavePitch);
	float* harmAbs = (float*)malloc(length * sizeof(float));
	float* harmArg = (float*)malloc(length * sizeof(float));
	float* interpAbs = (float*)malloc(length * config.batchSize * sizeof(float));
	float* interpArg = (float*)malloc(length * config.batchSize * sizeof(float));
	for (int i = 0; i < config.halfHarmonics; i++)
	{
		for (int j = 0; j < length; j++)
		{
			*(harmAbs + j) = *(specharm + j * config.frameSize + i);
			*(harmArg + j) = *(specharm + j * config.frameSize + config.halfHarmonics + i);
		}
		interp_exec(frameSpace, harmAbs, length, interpAbs, length * config.batchSize, harmInterpCaches);
		circInterp_inpl(frameSpace, harmArg, waveSpace, length, length * config.batchSize, interpArg);
		for (int j = 0; j < length * config.batchSize - 1; j++)
		{
			*(target + j) += cos(*(interpArg + j) + *(pitchOffsets + j) * 2. * pi * i) * *(interpAbs + j);
		}
	}
	interp_dealloc(harmInterpCaches);
	free(harmAbs);
	free(harmArg);
	free(interpAbs);
	free(interpArg);
	free(pitchOffsets);
	free(frameSpace);
	free(waveSpace);
}

//renders a specharm signal. The result is written into the target array.
void LIBESPER_CDECL render(float* specharm, float* pitch, float* phase, float* target, int length, engineCfg config)
{
	for (int i = 0; i < length * config.batchSize; i++)
	{
		*(target + i) = 0;
	}
	renderUnvoiced(specharm, target, length, config);
	renderVoiced(specharm, pitch, phase, target, length, config);
}
