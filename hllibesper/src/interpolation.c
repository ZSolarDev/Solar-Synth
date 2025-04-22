//Copyright 2023 - 2024 Johannes Klatt

//This file is part of libESPER.
//libESPER is free software: you can redistribute it and /or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or any later version.
//libESPER is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//You should have received a copy of the GNU General Public License along with Nova - Vox.If not, see <https://www.gnu.org/licenses/>.

#include "interpolation.h"

#include <stdlib.h>
#include <math.h>
#include "util.h"

//Utility function for batched calculation of Hermite polynomials. Used by interp_inpl() and functions derived from it.
float* hPoly(float* input, int length)
{
    //tile input 4 times and apply a different exponential to each version
    float* temp = (float*)malloc(4 * length * sizeof(float));
    for (int i = 0; i < 4; i++)
    {
        for (int j = 0; j < length; j++)
        {
            *(temp + j + i * length) = pow(*(input + j), i);
        }
    }
    //coefficient matrix
    float matrix[4][4] = { {1, 0, -3, 2},
                           {0, 1, -2, 1},
                           {0, 0, 3, -2},
                           {0, 0, -1, 1} };
    //allocate output buffer
    float* output = (float*)malloc(4 * length * sizeof(float));
    //perform matrix multiplication of tiled input and coefficient matrix
    for (int i = 0; i < 4; i++)
    {
        for (int j = 0; j < length; j++)
        {
            *(output + j + i * length) = 0;
            for (int k = 0; k < 4; k++)
            {
                *(output + j + i * length) += *(temp + j + k * length) * matrix[i][k];
            }
        }
    }
    free(temp);
    return output;
}

//performs batched interpolation of y coordinates belonging to points with x coordinates given by xs, using the points (x, y) as guides
//len refers to the length of x and y, which need to be equal, while lenxs refers to the length of xs and the result.
//all input arrays are expected to be sorted.
float* interp(float* x, float* y, float* xs, int len, int lenxs)
{
    float* ys = (float*) malloc(lenxs * sizeof(float));
    interp_inpl(x, y, xs, len, lenxs, ys);
    return ys;
}

//setup function for interpolation. Calculates the Hermite polynomials and the indices of the x values closest to the xs values.
interp_caches interp_setup(float* x, float* xs, int len, int lenxs)
{
	interp_caches caches;
    caches.m = (float*)malloc(len * sizeof(float));
    caches.idxs = (float*)malloc(lenxs * sizeof(float));
    int i = 0; //iterator for xs
    int j = 0; //iterator for x
    while ((j < len - 1) && (i < lenxs)) //since both x and xs are sorted, iterating linearly is O(n), compared to O(n log n) for repeated binary search
    {
        if (*(xs + i) > *(x + j + 1))
        {
            j++;
        }
        else
        {
            *(caches.idxs + i) = j;
            i++;
        }
    }
    while (i < lenxs) //all remaining points are behind the last element of x
    {
        *(caches.idxs + i) = j;
        i++;
    }
	caches.dx = (float*)malloc(lenxs * sizeof(float));
    float* hh = (float*)malloc(lenxs * sizeof(float));
    int offset;
    for (int i = 0; i < lenxs; i++)
    {
        offset = *(caches.idxs + i);
        *(caches.dx + i) = *(x + 1 + offset) - *(x + offset);
        *(hh + i) = (*(xs + i) - *(x + offset)) / *(caches.dx + i);
    }
    caches.h = hPoly(hh, lenxs);
    free(hh);
	return caches;
}

//main function for interpolation. Writes the result into the ys buffer. The caches argument is expected to be filled by interp_setup().
//The caches remain valid after the function returns, and can be used for multiple calls to interp_exec().
void interp_exec(float* x, float* y, int len, float* ys, int lenxs, interp_caches caches)
{
    for (int i = 0; i < (len - 1); i++)
    {
        *(caches.m + i + 1) = (*(y + i + 1) - *(y + i)) / (*(x + i + 1) - *(x + i));
    }
    *caches.m = *(caches.m + 1);
    for (int i = 1; i < (len - 1); i++)
    {
        *(caches.m + i) = (*(caches.m + i) + *(caches.m + i + 1)) / 2.;
    }
	int offset;
	for (int i = 0; i < lenxs; i++)
	{
		offset = *(caches.idxs + i);
		*(ys + i) = (*(caches.h + i) * *(y + offset)) + (*(caches.h + i + lenxs) * *(caches.m + offset) * *(caches.dx + i)) + (*(caches.h + i + 2 * lenxs) * *(y + offset + 1)) + (*(caches.h + i + 3 * lenxs) * *(caches.m + offset + 1) * *(caches.dx + i));
	}
}

//deallocates the caches created by interp_setup()
void interp_dealloc(interp_caches caches)
{
	free(caches.m);
	free(caches.idxs);
	free(caches.dx);
	free(caches.h);
}

//in-place version of interp() that writes the result back into the ys buffer
void interp_inpl(float* x, float* y, float* xs, int len, int lenxs, float* ys)
{
    if (*xs < *x) printf("interpolation input too low! %f %f\n", *xs, *x);
    if (*(xs + lenxs - 1) > *(x + len - 1)) printf("interpolation input too high! %f %f\n", *(xs + lenxs - 1), *(x + len - 1));
	interp_caches caches = interp_setup(x, xs, len, lenxs);
	interp_exec(x, y, len, ys, lenxs, caches);
	interp_dealloc(caches);
}

//wrapper around interp() that supports basic extrapolation, instead of having undefined behavior for xs values outside the range of x.
float* extrap(float* x, float* y, float* xs, int len, int lenxs)
{
    //perform extrapolation
    float largeY = *(y + len - 1) + (*(y + len - 1) - *(y + len - 2)) * (*(xs + lenxs - 1) - *(x + len - 1)) / (*(x + len - 1) - *(x + len - 2));
    float smallY = *y - (*(y + 1) - *y) * (*x - *xs) / (*(x + 1) - *x);
    float* xnew;
    float* ynew;
    //flag indicating whether the xnew and ynew buffers need to be de-allocated
    int freeNew = 1;
    int newLen = len;
    if ((*xs < *x) && (*(xs + lenxs - 1) > *(x + len - 1))) //both append and prepend required
    {
        xnew = (float*) malloc((len + 2) * sizeof(float));
        ynew = (float*) malloc((len + 2) * sizeof(float));
        for (int i = 0; i < len; i++)
        {
            *(xnew + i + 1) = *(x + i);
            *(ynew + i + 1) = *(y + i);
        }
        *xnew = *xs;
        *ynew = smallY;
        *(xnew + len + 1) = *(xs + lenxs - 1);
        *(ynew + len + 1) = largeY;
        newLen += 2;
    }
    else
    {
        if (*xs < *x) //only prepend required
        {
            xnew = (float*) malloc((len + 1) * sizeof(float));
            ynew = (float*) malloc((len + 1) * sizeof(float));
            for (int i = 0; i < len; i++)
            {
                *(xnew + i + 1) = *(x + i);
                *(ynew + i + 1) = *(y + i);
            }
            *xnew = *xs;
            *ynew = smallY;
            newLen++;
        }
        else if (*(xs + lenxs - 1) > *(x + len - 1)) //only append required
        {
            xnew = (float*) malloc((len + 1) * sizeof(float));
            ynew = (float*) malloc((len + 1) * sizeof(float));
            for (int i = 0; i < len; i++)
            {
                *(xnew + i) = *(x + i);
                *(ynew + i) = *(y + i);
            }
            *(xnew + len) = *(xs + lenxs - 1);
            *(ynew + len) = largeY;
            newLen++;
        }
        else //neither append nor prepend required. Just call interp() without allocating a new buffer or adding extrapolated elements
        {
            xnew = x;
            ynew = y;
            freeNew = 0;
        }
    }
    //perform interpolation
    float* ys = interp(xnew, ynew, xs, newLen, lenxs);
    //free buffers if necessary
    if (freeNew == 1)
    {
        free(xnew);
        free(ynew);
    }
    return ys;
}

//in-place version of extrap() that writes the result back into the ys buffer
void extrap_inpl(float* x, float* y, float* xs, int len, int lenxs, float* ys)
{
    //perform extrapolation
    float largeY = *(y + len - 1) + (*(y + len - 1) - *(y + len - 2)) * (*(xs + lenxs - 1) - *(x + len - 1)) / (*(x + len - 1) - *(x + len - 2));
    float smallY = *y - (*(y + 1) - *y) * (*x - *xs) / (*(x + 1) - *x);
    float* xnew;
    float* ynew;
    //flag indicating whether the xnew and ynew buffers need to be de-allocated
    int freeNew = 1;
    int newLen = len;
    if ((*xs < *x) && (*(xs + lenxs - 1) > *(x + len - 1))) //both append and prepend required
    {
        xnew = (float*)malloc((len + 2) * sizeof(float));
        ynew = (float*)malloc((len + 2) * sizeof(float));
        for (int i = 0; i < len; i++)
        {
            *(xnew + i + 1) = *(x + i);
            *(ynew + i + 1) = *(y + i);
        }
        *xnew = *xs;
        *ynew = smallY;
        *(xnew + len + 1) = *(xs + lenxs - 1);
        *(ynew + len + 1) = largeY;
        newLen += 2;
    }
    else
    {
        if (*xs < *x) //only prepend required
        {
            xnew = (float*)malloc((len + 1) * sizeof(float));
            ynew = (float*)malloc((len + 1) * sizeof(float));
            for (int i = 0; i < len; i++)
            {
                *(xnew + i + 1) = *(x + i);
                *(ynew + i + 1) = *(y + i);
            }
            *xnew = *xs;
            *ynew = smallY;
            newLen++;
        }
        else if (*(xs + lenxs - 1) > *(x + len - 1)) //only append required
        {
            xnew = (float*)malloc((len + 1) * sizeof(float));
            ynew = (float*)malloc((len + 1) * sizeof(float));
            for (int i = 0; i < len; i++)
            {
                *(xnew + i) = *(x + i);
                *(ynew + i) = *(y + i);
            }
            *(xnew + len) = *(xs + lenxs - 1);
            *(ynew + len) = largeY;
            newLen++;
        }
        else //neither append nor prepend required. Just call interp() without allocating a new buffer or adding extrapolated elements
        {
            xnew = x;
            ynew = y;
            freeNew = 0;
        }
    }
    //perform interpolation
    interp_inpl(xnew, ynew, xs, newLen, lenxs, ys);
    //free buffers if necessary
    if (freeNew == 1)
    {
        free(xnew);
        free(ynew);
    }
}

//batched circular interpolation of y coordinates belonging to points with x coordinates given by xs, using the points (x, y) as guides
//x and xs coordinates are expected to be normalized to the range [-pi, pi]
float* circInterp(float* x, float* y, float* xs, int len, int lenxs)
{
    float* ys = (float*)malloc(lenxs * sizeof(float));
    float factor;
    float a;
    float b;
    circInterp_inpl(x, y, xs, len, lenxs, ys);
    return ys;
}

//in-place version of circInterp() that writes the result back into the ys buffer
//x and xs coordinates are expected to be normalized to the range [-pi, pi]
void circInterp_inpl(float* x, float* y, float* xs, int len, int lenxs, float* ys)
{
    int idx = 0;
    int idxs = 0;
    float factor;
    float a;
    float b;
    while (idxs < lenxs)
    {
        while ((*(xs + idxs) > *(x + idx + 1)) && (idx < (len - 1)))
        {
            idx++;
        }
        factor = (*(xs + idxs) - *(x + idx)) / (*(x + idx + 1) - *(x + idx));
        a = *(y + idx + 1) - *(y + idx);
        if (*(y + idx + 1) > *(y + idx))
        {
            b = a - 2. * pi;
        }
        else
        {
            b = a + 2. * pi;
        }
        if (fabsf(a) <= fabsf(b))
        {
            *(ys + idxs) = fmodf(*(y + idx) + factor * a, 2 * pi);
        }
        else
        {
            *(ys + idxs) = fmodf(*(y + idx) + factor * b, 2 * pi);
        }
        if (*(ys + idxs) > pi)
        {
            *(ys + idxs) -= 2. * pi;
        }
        else if (*(ys + idxs) <= -pi)
        {
            *(ys + idxs) += 2. * pi;
        }
        idxs++;
    }
}

//batched interpolation of two phases based on a factor.
//The interpolation always chooses the shortest possible angle between the two phases.
//The result is written back into phasesA.
void phaseInterp_inplace(float* phasesA, float* phasesB, int len, float factor)
{
    float a;
    float b;
    for (int i = 0; i < len; i++)
    {
        a = *(phasesB + i) - *(phasesA + i);
        b = *(phasesA + i) - *(phasesB + i);
        if (a < -pi)
        {
            a += 2 * pi;
        }
        else if (a > pi)
        {
            a -= 2 * pi;
        }
        if (b < -pi)
        {
            b += 2 * pi;
        }
        else if (b > pi)
        {
            b -= 2 * pi;
        }
        if (fabsf(a) <= fabsf(b))
        {
            *(phasesA + i) += a * factor;
        }
        else
        {
            *(phasesA + i) += b * factor;
        }
        if (*(phasesA + i) < -pi)
        {
            *(phasesA + i) += 2 * pi;
        }
        else if (*(phasesA + i) > pi)
        {
            *(phasesA + i) -= 2 * pi;
        }
    }
}
