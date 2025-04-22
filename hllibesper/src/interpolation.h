//Copyright 2023 - 2024 Johannes Klatt

//This file is part of libESPER.
//libESPER is free software: you can redistribute it and /or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or any later version.
//libESPER is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//You should have received a copy of the GNU General Public License along with Nova - Vox.If not, see <https://www.gnu.org/licenses/>.

#pragma once

float* interp(float* x, float* y, float* xs, int len, int lenxs);

typedef struct
{
    float* m;
    float* idxs;
    float* dx;
    float* h;
} interp_caches;

interp_caches interp_setup(float* x, float* xs, int len, int lenxs);

void interp_exec(float* x, float* y, int len, float* ys, int lenxs, interp_caches caches);

void interp_dealloc(interp_caches caches);

void interp_inpl(float* x, float* y, float* xs, int len, int lenxs, float* ys);

float* extrap(float* x, float* y, float* xs, int len, int lenxs);

void extrap_inpl(float* x, float* y, float* xs, int len, int lenxs, float* ys);

float* circInterp(float* x, float* y, float* xs, int len, int lenxs);

void circInterp_inpl(float* x, float* y, float* xs, int len, int lenxs, float* ys);

void phaseInterp_inplace(float* phasesA, float* phasesB, int len, float factor);
