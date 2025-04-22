//Copyright 2024 Johannes Klatt

//This file is part of libESPER.
//libESPER is free software: you can redistribute it and /or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or any later version.
//libESPER is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//You should have received a copy of the GNU General Public License along with Nova - Vox.If not, see <https://www.gnu.org/licenses/>.

#include "util.h"

LIBESPER_EXPORT void LIBESPER_CDECL applyBreathiness(float* specharm, float* breathiness, int length, engineCfg config);

LIBESPER_EXPORT void LIBESPER_CDECL pitchShift(float* specharm, float* srcPitch, float* tgtPitch, float* formantShift, float* breathiness, int length, engineCfg config);

LIBESPER_EXPORT void LIBESPER_CDECL applyDynamics(float* specharm, float* dynamics, float* pitch, int length, engineCfg config);

LIBESPER_EXPORT void LIBESPER_CDECL applyBrightness(float* specharm, float* brightness, int length, engineCfg config);

LIBESPER_EXPORT void LIBESPER_CDECL applyGrowl(float* specharm, float* growl, float* lfoPhase, int length, engineCfg config);

LIBESPER_EXPORT void LIBESPER_CDECL applyRoughness(float* specharm, float* roughness, int length, engineCfg config);