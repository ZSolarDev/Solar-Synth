//Copyright 2023 Johannes Klatt

//This file is part of libESPER.
//libESPER is free software: you can redistribute it and /or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or any later version.
//libESPER is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//You should have received a copy of the GNU General Public License along with Nova - Vox.If not, see <https://www.gnu.org/licenses/>.

#include "util.h"

#include <malloc.h>
#include <math.h>
#include <stdlib.h>
#include <float.h>
#include LIBESPER_FFTW_INCLUDE_PATH

//initializes a dynamic integer array, and allocates memory for it
void dynIntArray_init(dynIntArray* array)
{
    (*array).content = (int*) malloc(sizeof(int));
    (*array).length = 0;
    (*array).maxlen = 1;
}

//de-allocates the memory of a dynamic integer array and marks it as unusable
void dynIntArray_dealloc(dynIntArray* array)
{
    free((*array).content);
    (*array).length = 0;
    (*array).maxlen = 0;
}

//appends a new value to the end of a dynamic integer array, and expands it if necessary
void dynIntArray_append(dynIntArray* array, int value) {
    if ((*array).length == (*array).maxlen) {
        (*array).content = (int*) realloc((*array).content, 2 * (*array).maxlen * sizeof(int));
        (*array).maxlen *= 2;
    }
    *((*array).content + (*array).length) = value;
    (*array).length++;
}

//Utility function for dividing two integers and rounding up the result
int ceildiv(int numerator, int denominator)
{
    return (numerator + denominator - 1) / denominator;
}

//given a sorted array "markers" of integers, finds the index that the element "position" would have in that array.
//Uses binary search.
unsigned int findIndex(int* markers, unsigned int markerLength, int position)
{
    int low = -1;
    int high = markerLength;
    int mid;
    while (low + 1 < high)
    {
        mid = (low + high) / 2;
        if (position > *(markers + mid))
        {
            low = mid;
        }
        else
        {
            high = mid;
        }
    }
    return (unsigned int)high;
}

//given a sorted array "markers" of doubles, finds the index that the element "position" would have in that array.
//Uses binary search.
unsigned int findIndex_double(double* markers, unsigned int markerLength, int position)
{
    int low = -1;
    int high = markerLength;
    int mid;
    while (low + 1 < high)
    {
        mid = (low + high) / 2;
        if ((double)position > *(markers + mid))
        {
            low = mid;
        }
        else
        {
            high = mid;
        }
    }
    return (unsigned int)high;
}

//compares two unsigned integers for qsort
int compare_uint(const void* a, const void* b)
{
	return (*(unsigned int*)a - *(unsigned int*)b);
}

//calculates the median of an array of unsigned integers
//Does NOT preserve the order of the array.
unsigned int median(unsigned int* array, unsigned int length)
{
	qsort(array, length, sizeof(unsigned int), compare_uint);
	unsigned int median;
	if (length % 2 == 0)
	{
		median = (*(array + length / 2) + *(array + length / 2 - 1)) / 2;
	}
	else
	{
		median = *(array + length / 2);
	}
	return median;
}

//compares two floats for qsort
int compare_float(const void* a, const void* b)
{
    if (*(float*)a < *(float*)b)
    {
        return -1;
    }
    if (*(float*)a > *(float*)b)
    {
        return 1;
    }
    return 0;
}

//calculates the median of an array of floats
//Does NOT preserve the order of the array.
float medianf(float* array, unsigned int length)
{
	qsort(array, length, sizeof(float), compare_float);
	float median;
	if (length % 2 == 0)
	{
		median = (*(array + length / 2) + *(array + length / 2 - 1)) / 2;
	}
	else
	{
		median = *(array + length / 2);
	}
	return median;
}


//calculates the absolute value of a complex number.
float cpxAbsf(fftwf_complex input)
{
    return sqrtf(powf(input[0], 2) + powf(input[1], 2));
}

//calculates the absolute value of a double precision complex number.
double cpxAbsd(fftw_complex input)
{
    return sqrtf(pow(input[0], 2) + pow(input[1], 2));
}

//calculates the phase angle of a complex number
float cpxArgf(fftwf_complex input)
{
    return atan2f(input[1], input[0]);
}

//calculates the phase angle of a double precision complex number
double cpxArgd(fftw_complex input)
{
    return atan2(input[1], input[0]);
}

//returns an array of floats representing a hanning window of a given length, multiplied by a given factor and an additional factor of 2/3,
// to account for the energy loss of the window and the 3 window overlap used in STFT operations.
float* hannWindow(int length, float multiplier)
{
    float* hannWindow = (float*)malloc(length * sizeof(float));
    for (int i = 0; i < length; i++) {
        *(hannWindow + i) = pow(sin((pi / length) * i), 2.) * multiplier * 2. / 3.;
    }
    return hannWindow;
}

//returns a pseudorandom float value sampled from a normal distribution with a given mean and standard deviation.
float random_normal(float mean, float stddev)
{
    double u1 = (double)rand() / (double)RAND_MAX;
    double u2 = (double)rand() / (double)RAND_MAX;
	if (u1 <= DBL_MIN)
	{
		u1 = 0.5;
	}
	float z = sqrt(-2. * log(u1)) * cos(2. * pi * u2);
	return mean + z * stddev;
}

//the number pi
extern float pi = 3.1415926535897932384626433;
