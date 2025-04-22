//Copyright 2023 - 2024 Johannes Klatt

//This file is part of libESPER.
//libESPER is free software: you can redistribute it and /or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or any later version.
//libESPER is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//You should have received a copy of the GNU General Public License along with Nova - Vox.If not, see <https://www.gnu.org/licenses/>.

#include "ESPER/components.h"

#include <malloc.h>
#include <math.h>
#include <stdio.h>
#include "util.h"
#include "fft.h"
#include "interpolation.h"
#include LIBESPER_FFTW_INCLUDE_PATH
#include LIBESPER_NFFT_INCLUDE_PATH

//smoothes the unvoiced part of a specharm signal in fourier space, i.e. makes each fourier coefficient influence its neighbors.
void smoothFourierSpace(cSample sample, engineCfg config) {
	float* workingSpectrum = (float*)malloc((config.halfTripleBatchSize + 1) * sizeof(float));
    for (int i = 0; i < sample.config.batches; i++)
    {
		*workingSpectrum =
            *(sample.specharm + i * config.frameSize + config.nHarmonics + 2) * 0.75 +
            *(sample.specharm + i * config.frameSize + config.nHarmonics + 3) * 0.25;
        for (int j = 1; j < config.halfTripleBatchSize; j++)
        {
            *(workingSpectrum + j) =
                *(sample.specharm + i * config.frameSize + config.nHarmonics + 2 + j) * 0.5 +
                *(sample.specharm + i * config.frameSize + config.nHarmonics + 1 + j) * 0.25 +
                *(sample.specharm + i * config.frameSize + config.nHarmonics + 3 + j) * 0.25;
        }
		*(workingSpectrum + config.halfTripleBatchSize) =
			*(sample.specharm + i * config.frameSize + config.nHarmonics + 2 + config.halfTripleBatchSize) * 0.75 +
			*(sample.specharm + i * config.frameSize + config.nHarmonics + 1 + config.halfTripleBatchSize) * 0.25;
		for (int j = 0; j < config.halfTripleBatchSize + 1; j++)
		{
			*(sample.specharm + i * config.frameSize + config.nHarmonics + 2 + j) = *(workingSpectrum + j);
		}
    }
	free(workingSpectrum);
}

//smoothes the unvoiced part of a specharm signal in temporal space, i.e. makes each time point influence its neighbors.
void smoothTempSpace(cSample sample, engineCfg config)
{
	float* medianBuffer = (float*)malloc(sample.config.tempWidth * sizeof(float));
	float* resultBuffer = (float*)malloc(sample.config.batches * sizeof(float));
    for (int i = 0; i < config.halfTripleBatchSize + 1; i++)
    {
		for (int j = 0; j < sample.config.batches; j++)
		{
			for (int k = 0; k < sample.config.tempWidth; k++)
			{
				int index = j + k - sample.config.tempWidth / 2;
				if (index < 0 || index >= sample.config.batches)
				{
                    *(medianBuffer + k) = 0.;
				}
				else
				{
                    *(medianBuffer + k) = *(sample.specharm + index * config.frameSize + config.nHarmonics + 2 + i);
				}
			}
			*(resultBuffer + j) = medianf(medianBuffer, sample.config.tempWidth);
		}
        for (int j = 0; j < sample.config.batches; j++)
        {
            *(sample.specharm + j * config.frameSize + config.nHarmonics + 2 + i) = *(resultBuffer + j);
        }
    }
	free(medianBuffer);
	free(resultBuffer);
}

//constructs a set of evaluation points, i.e. per-sample pitch-synchronous coordinates, for a sample object with existing pitch data.
float* getEvaluationPoints(int start, int end, float* wave, cSample sample, engineCfg config)
{
    float* localMarkers = (float*)malloc((end - start + 1) * sizeof(float));
    float* markerSpace = (float*)malloc((end - start + 1) * sizeof(float));
    for (int j = 0; j <= end - start; j++)
    {
        *(localMarkers + j) = *(sample.pitchMarkers + start + j) - (int)ceil(*(sample.pitchMarkers + start));
        *(markerSpace + j) = j;
    }
	int windowLength = *(sample.pitchMarkers + end) - *(sample.pitchMarkers + start);
    float* windowSpace = (float*)malloc(windowLength * sizeof(float));
    for (int j = 0; j < windowLength; j++)
    {
        *(windowSpace + j) = j;
    }
    //evaluation points contain pitch-synchronous coordinate for each waveform element in the offset window
    float* evaluationPoints = extrap(localMarkers, markerSpace, windowSpace, end - start + 1, windowLength);
    free(localMarkers);
    free(markerSpace);
    free(windowSpace);
	return evaluationPoints;
}

//performs voiced-unvoiced separation for a single time window within a sample object.
//the result is a set of fourier coefficients for the voiced part of the window, which are written to the appropriate location in the result array.
void separateVoicedUnvoicedSingleWindow(int index, float* evaluationPoints, fftw_complex* result, cSample sample, engineCfg config)
{
	int windowStart = *(sample.pitchMarkers + index);
    int windowLength = *(sample.pitchMarkers + index + 1) - windowStart;
    float* windowPtr = sample.waveform + windowStart;
    
    nfft_plan combinedNUFFT;
    nfft_init_1d(&combinedNUFFT, config.nHarmonics, windowLength);
    for (int i = 0; i < windowLength; i++)
    {
        combinedNUFFT.x[i] = *(evaluationPoints + windowStart + i);
		if (combinedNUFFT.x[i] > 0.5)
		{
			combinedNUFFT.x[i] -= 1.;
		}
    }
    if (combinedNUFFT.flags & PRE_ONE_PSI)
    {
        nfft_precompute_one_psi(&combinedNUFFT);
    }
    for (int i = 0; i < windowLength; i++)
    {
        (*(combinedNUFFT.f + i))[0] = *(windowPtr + i) / (float)(windowLength);
        (*(combinedNUFFT.f + i))[1] = 0.;
    }
    nfft_adjoint_1d(&combinedNUFFT);
    for (int i = 0; i < config.halfHarmonics; i++)
    {
        (*(result + index * config.halfHarmonics + i))[0] = (*(combinedNUFFT.f_hat + i))[0];
        (*(result + index * config.halfHarmonics + i))[1] = (*(combinedNUFFT.f_hat + i))[1];
    }
    nfft_finalize(&combinedNUFFT);
}

//compares two float values for sorting purposes.
int compareFloats(const void* a, const void* b)
{
    float diff = (*(const float*)a - *(const float*)b);
    if (diff < 0) return -1;
    if (diff > 0) return 1;
    return 0;
}

//constructs a symmetric gaussian window of a given length and standard deviation.
//the window is normalized to sum to 1.
float* gaussWindow(int length, float sigma)
{
	float* window = (float*)malloc(length * sizeof(float));
	for (int i = 0; i < length; i++)
	{
		*(window + i) = exp(-0.5 * pow((float)(i - length / 2) / sigma, 2));
	}
	//normalize window with respect to discretization error
	float sum = 0.;
	for (int i = 0; i < length; i++)
	{
		sum += *(window + i);
	}
	for (int i = 0; i < length; i++)
	{
		*(window + i) /= sum;
	}
	return window;
}

float squaredDistance(float x1, float y1, float x2, float y2)
{
	return powf(x1 - x2, 2) + powf(y1 - y2, 2);
}

float squaredDistance_cpx(fftw_complex cpx1, fftw_complex cpx2)
{
	return powf(cpx1[0] - cpx2[0], 2) + powf(cpx1[1] - cpx2[1], 2);
}

void weightedDistance(fftw_complex point, fftw_complex mean, float variance, float weight, fftw_complex* result)
{
    (*result)[0] = mean[0];
	(*result)[1] = mean[1];
    return;
	if (variance == 0.)
	{
		(*result)[0] = mean[0];
		(*result)[1] = mean[1];
		return;
	}
	float distance = squaredDistance_cpx(point, mean);
    weight *= exp(-distance / (2. * variance));
    if (weight > 1.)
	{
		weight = 1.;
	}
    (*result)[0] = mean[0] +(point[0] - mean[0]) * weight;
    (*result)[1] = mean[1] +(point[1] - mean[1]) * weight;
}

//post-processing for voiced-unvoiced separation after all windows have been processed.
//applies adaptive smoothing to the assumed voiced part of the signal.
void separateVoicedUnvoicedPostProc(fftw_complex* dftCoeffs, cSample sample, engineCfg config)
{
    int effectiveLength = sample.config.markerLength - 1;
    int kernelSize = 10;
    if (effectiveLength < kernelSize)
    {
        return;
    }
    fftw_complex* smoothedDftCoeffs = (fftw_complex*)malloc(effectiveLength * config.halfHarmonics * sizeof(fftw_complex));
    float* leftSum = (float*)malloc(2 * config.halfHarmonics * sizeof(float));
    float* rightSum = (float*)malloc(2 * config.halfHarmonics * sizeof(float));
    for (int i = 0; i < effectiveLength; i++)
    {
        //get correct pointer to dftCoeffs
        int index = i - kernelSize / 2;
        if (index < 0)
        {
            index = 0;
        }
        else if (index > effectiveLength - kernelSize)
        {
            index = effectiveLength - kernelSize;
        }
        fftw_complex* window = dftCoeffs + index * config.halfHarmonics;
        //initialize required variables
        char jumpPoint = 1;
        float threshold = 0;
        int leftSize = 1;
		int rightSize = kernelSize - 1;
        for (int j = 0; j < config.halfHarmonics; j++)
        {
			leftSum[2 * j] = (*(window + j))[0];
			leftSum[2 * j + 1] = (*(window + j))[1];
			rightSum[2 * j] = 0.;
			rightSum[2 * j + 1] = 0.;
            for (int k = 1; k < kernelSize; k++)
            {
				if (sample.pitchMarkerValidity[index + k] == 0)
				{
					rightSize--;
					continue;
				}
				rightSum[2 * j] += (*(window + j + config.halfHarmonics * k))[0];
				rightSum[2 * j + 1] += (*(window + j + config.halfHarmonics * k))[1];
            }
		}
		//find jump point
		for (int j = 1; j < kernelSize; j++)
		{
			if (sample.pitchMarkerValidity[index + j] == 0)
			{
				continue;
			}
            float distance = 0.;
			for (int k = 0; k < config.halfHarmonics; k++)
			{
                fftw_complex leftMean = { leftSum[2 * k] / leftSize, leftSum[2 * k + 1] / leftSize };
				fftw_complex rightMean = { rightSum[2 * k] / rightSize, rightSum[2 * k + 1] / rightSize };
				distance += squaredDistance_cpx(leftMean, rightMean);
			}
			if (distance > threshold)
			{
				threshold = distance;
				jumpPoint = j;
			}
            for (int k = 0; k < config.halfHarmonics; k++)
            {
                leftSum[2 * k] += (*(window + k + config.halfHarmonics * j))[0];
                leftSum[2 * k + 1] += (*(window + k + config.halfHarmonics * j))[1];
                rightSum[2 * k] -= (*(window + k + config.halfHarmonics * j))[0];
                rightSum[2 * k + 1] -= (*(window + k + config.halfHarmonics * j))[1];
            }
			leftSize++;
			rightSize--;
		}
        //calculate mean of the side containing the window center
        for (int j = 0; j < config.halfHarmonics; j++)
        {
			leftSum[2 * j] = 0.;
			leftSum[2 * j + 1] = 0.;
        }
		float variance = 0.;
        
        if (jumpPoint >= kernelSize / 2)
		{
			for (int j = 0; j < config.halfHarmonics; j++)
			{
                leftSize = 0;
				for (int k = 0; k < jumpPoint; k++)
				{
					if (sample.pitchMarkerValidity[index + k] == 0)
					{
						continue;
					}
					leftSum[2 * j] += (*(window + j + config.halfHarmonics * k))[0];
					leftSum[2 * j + 1] += (*(window + j + config.halfHarmonics * k))[1];
					leftSize++;
				}
				leftSum[2 * j] /= leftSize;
                leftSum[2 * j + 1] /= leftSize;
				for (int k = 0; k < jumpPoint; k++)
				{
					if (sample.pitchMarkerValidity[index + k] == 0)
					{
						continue;
					}
					variance += squaredDistance(*(window + j + config.halfHarmonics * k)[0], *(window + j + config.halfHarmonics * k)[1], leftSum[2 * j], leftSum[2 * j + 1]);
				}
			}
			variance /= leftSize * config.halfHarmonics;
		}
		else
		{
			for (int j = j = 0; j < config.halfHarmonics; j++)
			{
				leftSize = 0;
				for (int k = jumpPoint; k < kernelSize; k++)
				{
					if (sample.pitchMarkerValidity[index + k] == 0)
					{
						continue;
					}
					leftSum[2 * j] += (*(window + j + config.halfHarmonics * k))[0];
					leftSum[2 * j + 1] += (*(window + j + config.halfHarmonics * k))[1];
					leftSize++;
				}
				leftSum[2 * j] /= leftSize;
				leftSum[2 * j + 1] /= leftSize;
				for (int k = jumpPoint; k < kernelSize; k++)
				{
					if (sample.pitchMarkerValidity[index + k] == 0)
					{
						continue;
					}
					variance += squaredDistance(*(window + j + config.halfHarmonics * k)[0], *(window + j + config.halfHarmonics * k)[1], leftSum[2 * j], leftSum[2 * j + 1]);
				}
			}
			variance /= leftSize * config.halfHarmonics;
		}
        for (int j = 0; j < config.halfHarmonics; j++)
        {
			fftw_complex mean = { leftSum[2 * j], leftSum[2 * j + 1] };
            weightedDistance(*(window + j + config.halfHarmonics * kernelSize / 2), mean, variance, 1. - powf((float)j / (float)config.halfHarmonics, 2.), smoothedDftCoeffs + i * config.halfHarmonics + j);
        }
	}
    //copy smoothedDftCoeffs to dftCoeffs
    for (int i = 0; i < effectiveLength * config.halfHarmonics; i++)
    {
        (*(dftCoeffs + i))[0] = (*(smoothedDftCoeffs + i))[0];
        (*(dftCoeffs + i))[1] = (*(smoothedDftCoeffs + i))[1];
	}
    free(smoothedDftCoeffs);
	free(leftSum);
	free(rightSum);
}

//constructs a voiced signal from a set of fourier coefficients, and saves it in the sample object.
void constructVoicedSignal(fftw_complex* dftCoeffs, cSample sample, engineCfg config)
{
	int windowStart = 0;
    int windowEnd = config.tripleBatchSize;
    int markerStart = 0;
    int markerEnd = 0;
    dynIntArray windowPoints;
	dynIntArray_init(&windowPoints);
    for (int i = 0; i < sample.config.batches; i++)
    {
        windowPoints.length = 0;
        while (*(sample.pitchMarkers + markerStart) < windowStart)
        {
			if (markerStart >= sample.config.markerLength - 1)
			{
				break;
			}
            markerStart++;
        }
        markerEnd = markerStart;
        while (*(sample.pitchMarkers + markerEnd) < windowEnd)
        {
            if (markerEnd >= sample.config.markerLength - 1)
            {
                break;
            }
			if (*(sample.pitchMarkerValidity + markerEnd) == 0)
			{
				markerEnd++;
				continue;
			}
            dynIntArray_append(&windowPoints, markerEnd);
            markerEnd++;
        }
        if (windowPoints.length == 0)
        {
            int previous = markerStart - 1;
            if (previous < 0)
            {
                previous = 0;
            }
			if (sample.pitchMarkerValidity[previous] == 0)
			{
				previous--;
			}
            int next = markerEnd;
			if (next >= sample.config.markerLength - 1)
			{
				next = sample.config.markerLength - 2;
			}
			if (sample.pitchMarkerValidity[next] == 0)
			{
				next++;
			}
            dynIntArray_append(&windowPoints, previous);
            dynIntArray_append(&windowPoints, next);
			windowPoints.length = 2;
        }
        windowStart += config.batchSize;
        windowEnd += config.batchSize;
        for (int j = 0; j < config.halfHarmonics; j++)
        {
            float real = 0.;
		    float imag = 0.;
            float abs = 0.;
            for (int k = 0; k < windowPoints.length; k++)
            {
			    int coord = *(windowPoints.content + k);
			    real += (*(dftCoeffs + coord * config.halfHarmonics + j))[0];
			    imag += (*(dftCoeffs + coord * config.halfHarmonics + j))[1];
                abs += cpxAbsd(*(dftCoeffs + coord * config.halfHarmonics + j));
            }
			abs /= windowPoints.length;
			fftw_complex cpx = { real, imag };
			*(sample.specharm + i * config.frameSize + config.halfHarmonics - 1 - j) = abs * 2;
            *(sample.specharm + i * config.frameSize + config.nHarmonics + 1 - j) = cpxArgd(cpx);
        }
		float principalPhase = *(sample.specharm + i * config.frameSize + config.halfHarmonics + 1);
        for (int j = 0; j < config.halfHarmonics; j++)
        {
			*(sample.specharm + i * config.frameSize + config.halfHarmonics + j) -= (float)(j) * principalPhase;
			*(sample.specharm + i * config.frameSize + config.halfHarmonics + j) = fmodf(*(sample.specharm + i * config.frameSize + config.halfHarmonics + j), 2. * pi);
            if (*(sample.specharm + i * config.frameSize + config.halfHarmonics + j) > pi)
            {
                *(sample.specharm + i * config.frameSize + config.halfHarmonics + j) -= 2. * pi;
            }
			if (*(sample.specharm + i * config.frameSize + config.halfHarmonics + j) < -pi)
			{
				*(sample.specharm + i * config.frameSize + config.halfHarmonics + j) += 2. * pi;
			}
        }
    }
    dynIntArray_dealloc(&windowPoints);
}

//constructs an unvoiced signal from the difference between a set of voiced fourier coefficients and the waveform of a sample object.
void constructUnvoicedSignal(float* evaluationPoints, fftw_complex * dftCoeffs, float* unvoicedSignal, cSample sample, engineCfg config)
{
	for (int i = 0; i < sample.config.markerLength - 1; i++)
    {
        nfft_plan inverseNUFFT;
        int start_inner;
        int start_outer;
        if (i == 0)
		{
			start_inner = 0;
			start_outer = 0;
		}
        else
        {
            start_inner =  0.75 * *(sample.pitchMarkers + i) + 0.25 * *(sample.pitchMarkers + i + 1);
            start_outer =  0.75 * *(sample.pitchMarkers + i) + 0.25 * *(sample.pitchMarkers + i - 1);
        }
        int end_inner;
		int end_outer;
		if (i == sample.config.markerLength - 2)
		{
			end_inner = sample.config.length;
			end_outer = sample.config.length;
		}
        else
		{
            end_inner =  0.75 * *(sample.pitchMarkers + i + 1) + 0.25 * *(sample.pitchMarkers + i);
            end_outer =  0.75 * *(sample.pitchMarkers + i + 1) + 0.25 * *(sample.pitchMarkers + i + 2);
		}
		int length_inner = end_inner - start_inner;
		int length_outer = end_outer - start_outer;
        nfft_init_1d(&inverseNUFFT, config.nHarmonics, length_outer);
        for (int j = 0; j < length_outer; j++)
        {
            inverseNUFFT.x[j] = *(evaluationPoints + start_outer + j);

            if (inverseNUFFT.x[j] > 0.5)
            {
                inverseNUFFT.x[j] -= 1.;
            }
        }
        if (inverseNUFFT.flags & PRE_ONE_PSI)
        {
            nfft_precompute_one_psi(&inverseNUFFT);
        }
        for (int j = 0; j < config.halfHarmonics - 1; j++)
        {
            float abs = cpxAbsd(*(dftCoeffs + i * config.halfHarmonics + j + 1));
			float arg = cpxArgd(*(dftCoeffs + i * config.halfHarmonics + j + 1));
            inverseNUFFT.f_hat[config.nHarmonics - j - 1][0] = cos(arg) * abs;
            inverseNUFFT.f_hat[config.nHarmonics - j - 1][1] = sin(arg) * abs * -1.;
        }
        for (int j = 0; j < config.halfHarmonics; j++)
        {
            float abs = cpxAbsd(*(dftCoeffs + i * config.halfHarmonics + j));
			float arg = cpxArgd(*(dftCoeffs + i * config.halfHarmonics + j));
            inverseNUFFT.f_hat[j][0] = cos(arg) * abs;
            inverseNUFFT.f_hat[j][1] = sin(arg) * abs;
        }
        nfft_trafo_1d(&inverseNUFFT);

		/*float localPitch = *(sample.pitchMarkers + i + 1) - *(sample.pitchMarkers + i);
        float referencePitch;
		if (i == 0)
		{
			referencePitch = *(sample.pitchMarkers + i + 1) - *(sample.pitchMarkers + i);
		}
		else
		{
			referencePitch = *(sample.pitchMarkers + i) - *(sample.pitchMarkers + i - 1);
		}
        if (i == sample.config.markerLength - 2)
        {
            referencePitch += *(sample.pitchMarkers + i + 1) - *(sample.pitchMarkers + i);
        }
        else
		{
			referencePitch += *(sample.pitchMarkers + i + 2) - *(sample.pitchMarkers + i + 1);
		}
		referencePitch /= 2;
        float pitchDivergence;
		if (localPitch + referencePitch == 0)
		{
			pitchDivergence = 0;
		}
		else if (localPitch > referencePitch)
		{
			pitchDivergence = (localPitch - referencePitch) / (localPitch + referencePitch);
		}
		else
		{
			pitchDivergence = (referencePitch - localPitch) / (localPitch + referencePitch);
		}*/
        float multiplier = 1.;// - pitchDivergence;
		if (sample.pitchMarkerValidity[i] == 0)
		{
			multiplier = 0.;
		}
		for (int j = 0; j < start_inner - start_outer; j++)
		{
            *(unvoicedSignal + start_outer + j) += (*(sample.waveform + start_outer + j) - inverseNUFFT.f[j][0]) * j / (start_inner - start_outer - 1) * multiplier;
		}
		for (int j = 0; j < length_inner; j++)
		{
            *(unvoicedSignal + start_inner + j) += (*(sample.waveform + start_inner + j) - inverseNUFFT.f[start_inner - start_outer + j][0]) * multiplier;
		}
		for (int j = 0; j < end_outer - end_inner; j++)
		{
            *(unvoicedSignal + end_inner + j) += (*(sample.waveform + end_inner + j) - inverseNUFFT.f[end_inner - start_outer + j][0]) * (end_outer - end_inner - 1 - j) / (end_outer - end_inner - 1) * multiplier;
		}
        nfft_finalize(&inverseNUFFT);
    }
}

//takes the waveform of an unvoiced signal and saves the corresponding fourier coefficients in the sample object.
void applyUnvoicedSignal(float* unvoicedSignal, cSample sample, engineCfg config)
{
    fftwf_complex* buffer = stft(unvoicedSignal, sample.config.length, config);
    for (int i = 0; i < sample.config.batches; i++)
    {
        for (int j = 0; j < config.halfTripleBatchSize + 1; j++)
        {
            *(sample.specharm + i * config.frameSize + config.nHarmonics + 2 + j) = cpxAbsf(*(buffer + i * (config.halfTripleBatchSize + 1) + j));
        }
    }
    free(buffer);
}

//separates voiced and unvoiced excitation of a sample through pitch-synchronous analysis.
//requires pitch data to be included in the sample struct.
void separateVoicedUnvoiced(cSample sample, engineCfg config)
{
    //separation calculations are only necessary if the sample is voiced
    if (sample.config.isVoiced == 0 || sample.config.markerLength < 2)
    {
        for (int i = 0; i < sample.config.batches; i++)
        {
            for (int j = 0; j < config.halfHarmonics; j++)
            {
                *(sample.specharm + i * config.frameSize + j) = 0;
            }
        }
		applyUnvoicedSignal(sample.waveform, sample, config);
		return;
    }
    float* unvoicedSignal = (float*)malloc(sample.config.length * sizeof(float));
    // fill input buffer, extend data with reflection padding on both sides
    for (int i = 0; i < sample.config.length; i++)
    {
        *(unvoicedSignal + i) = 0.f;
    }
    //Get DIO Pitch markers
    fftw_complex* dftCoeffs = (fftw_complex*)malloc((sample.config.markerLength - 1) * config.halfHarmonics * sizeof(fftw_complex));
	float* evaluationPoints = (float*)malloc(sample.config.length * sizeof(float));
    float* evalPart;
	for (int i = 0; i < *(sample.pitchMarkers); i++)
	{
		*(evaluationPoints + i) = (float)i / (float)*(sample.pitchMarkers);
	}
    if (sample.config.markerLength <= 8)
    {
		evalPart = getEvaluationPoints(0, sample.config.markerLength - 1, sample.waveform, sample, config);
        for (int i = *(sample.pitchMarkers); i < *(sample.pitchMarkers + sample.config.markerLength - 1); i++)
        {
            *(evaluationPoints + i) = fmodf(*(evalPart + i - *(sample.pitchMarkers)), 1.);
        }
		free(evalPart);
    }
    else
    {
        evalPart = getEvaluationPoints(0, 8, sample.waveform, sample, config);
        for (int i = *(sample.pitchMarkers); i < *(sample.pitchMarkers + 7); i++)
        {
            *(evaluationPoints + i) = fmodf(*(evalPart + i - *(sample.pitchMarkers)), 1.);
        }
        free(evalPart);
        for (int i = 6; i < sample.config.markerLength; i += 6)
        {
            if (i >= sample.config.markerLength - 9)
            {
                break;
            }
            evalPart = getEvaluationPoints(i, i + 8, sample.waveform, sample, config);
            for (int j = *(sample.pitchMarkers + i + 1); j < *(sample.pitchMarkers + i + 7); j++)
            {
                *(evaluationPoints + j) = fmodf(*(evalPart + j - *(sample.pitchMarkers + i)), 1.);
            }
            free(evalPart);
        }
        evalPart = getEvaluationPoints(sample.config.markerLength - 9, sample.config.markerLength - 1, sample.waveform, sample, config);
        for (int i = *(sample.pitchMarkers + sample.config.markerLength - 8); i < *(sample.pitchMarkers + sample.config.markerLength - 1); i++)
        {
            *(evaluationPoints + i) = fmodf(*(evalPart + i - *(sample.pitchMarkers + sample.config.markerLength - 9)), 1.);
        }
        free(evalPart);
    }
	int lastMarker = *(sample.pitchMarkers + sample.config.markerLength - 1);
	int postLength = sample.config.length - *(sample.pitchMarkers + sample.config.markerLength - 1);
	for (int i = 0; i < postLength; i++)
	{
		*(evaluationPoints + lastMarker + i) = (float)i / (float)postLength;
	}
    for (int i = 0; i < sample.config.markerLength - 1; i++)
    {
        separateVoicedUnvoicedSingleWindow(i, evaluationPoints, dftCoeffs, sample, config);
    }
    for (int i = 0; i < sample.config.markerLength - 1; i++)
    {
        if (*(sample.pitchMarkerValidity + i) == 0)
		{
			for (int j = 0; j < config.halfHarmonics; j++)
			{
				(*(dftCoeffs + i * config.halfHarmonics + j))[0] = ((*(dftCoeffs + (i - 1) * config.halfHarmonics + j))[0] + (*(dftCoeffs + (i + 1) * config.halfHarmonics + j))[0]) / 2;
				(*(dftCoeffs + i * config.halfHarmonics + j))[1] = ((*(dftCoeffs + (i - 1) * config.halfHarmonics + j))[1] + (*(dftCoeffs + (i + 1) * config.halfHarmonics + j))[1]) / 2;
			}
		}
	}
    separateVoicedUnvoicedPostProc(dftCoeffs, sample, config);
	constructVoicedSignal(dftCoeffs, sample, config);
	constructUnvoicedSignal(evaluationPoints, dftCoeffs, unvoicedSignal, sample, config);
	free(evaluationPoints);
    free(dftCoeffs);
	applyUnvoicedSignal(unvoicedSignal, sample, config);
    free(unvoicedSignal);
}

//averages all harmonic and unvoiced amplitudes, stores the result in the avgSpecharm field of the sample, and overwrites the specharms with their difference from the average.
//avgSpecharm is shorter than a specharm, since the harmonics phases are not stored in it.
void averageSpectra(cSample sample, engineCfg config)
{
    //average spectra
    for (int i = 0; i < config.halfHarmonics + config.halfTripleBatchSize + 1; i++)
    {
        *(sample.avgSpecharm + i) = 0.;
    }
    for (int i = 0; i < sample.config.batches; i++)
    {
        for (int j = 0; j < config.halfHarmonics; j++) {
            *(sample.avgSpecharm + j) += *(sample.specharm + i * config.frameSize + j);
        }
        for (int j = 0; j < config.halfTripleBatchSize + 1; j++)
        {
            *(sample.avgSpecharm + config.halfHarmonics + j) += *(sample.specharm + i * config.frameSize + config.nHarmonics + 2 + j);
        }
    }
    for (int i = 0; i < (config.halfHarmonics + config.halfTripleBatchSize + 1); i++)
    {
        *(sample.avgSpecharm + i) /= sample.config.batches;
    }
    for (int i = 0; i < sample.config.batches; i++)
    {
        for (int j = 0; j < config.halfHarmonics; j++)
        {
            *(sample.specharm + i * config.frameSize + j) -= *(sample.avgSpecharm + j);
        }
        for (int j = 0; j < config.halfTripleBatchSize + 1; j++)
        {
            *(sample.specharm + i * config.frameSize + config.nHarmonics + 2 + j) -= *(sample.avgSpecharm + config.halfHarmonics + j);
        }
    }
}

//dampens the influence of outliers in the specharm signal of a sample.
void dampenOutliers(cSample sample, engineCfg config)
{
    return;
    float variance = 0.;
    float* variances = (float*)malloc(sample.config.batches * sizeof(float));
    for (int i = 0; i < sample.config.batches; i++)
    {
        *(variances + i) = 0.;
    }
    for (int i = 0; i < sample.config.batches; i++) {
        for (int j = 0; j < config.halfHarmonics; j++) {
            *(variances + i) += pow(*(sample.specharm + i * config.frameSize + j), 2);
        }
        for (int j = 0; j < config.halfTripleBatchSize + 1; j++) {
            *(variances + i) += pow(*(sample.specharm + i * config.frameSize + config.nHarmonics + 2 + j), 2);
        }
    }
    for (int i = 0; i < sample.config.batches; i++) {
        *(variances + i) = sqrtf(*(variances + i));
        variance += *(variances + i);
    }
    variance /= sample.config.batches;
    for (int i = 0; i < sample.config.batches; i++) {
        *(variances + i) = *(variances + i) / variance - 1;
    }
    for (int i = 0; i < sample.config.batches; i++) {
        if (*(variances + i) > 1) {
            for (int j = 0; j < config.halfHarmonics; j++) {
                *(sample.specharm + i * config.frameSize + j) /= *(variances + i);
            }
            for (int j = config.nHarmonics + 2; j < config.halfTripleBatchSize + 1; j++) {
                *(sample.specharm + i * config.frameSize + j) /= *(variances + i);
            }
        }
    }
    free(variances);
}

//finalizes an analysed sample object by performing all necessary post-processing steps.
void finalizeSample(cSample sample, engineCfg config)
{
    averageSpectra(sample, config);
    if (sample.config.useVariance > 0)
    {
        dampenOutliers(sample, config);
    }
}
