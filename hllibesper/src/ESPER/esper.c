//Copyright 2023 - 2024 Johannes Klatt

//This file is part of libESPER.
//libESPER is free software: you can redistribute it and /or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or any later version.
//libESPER is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//You should have received a copy of the GNU General Public License along with Nova - Vox.If not, see <https://www.gnu.org/licenses/>.

#include "ESPER/esper.h"

#include <malloc.h>
#include "util.h"
#include "ESPER/components.h"
#include LIBESPER_FFTW_INCLUDE_PATH

//main function for ESPER audio analysis. Accepts a cSample as argument, and writes the results of the analysis back into the appropriate fields of the sample.
void LIBESPER_CDECL specCalc(cSample sample, engineCfg config)
{
    sample.config.batches = sample.config.length / config.batchSize;
    separateVoicedUnvoiced(sample, config);
    //smoothFourierSpace(sample, config);
	//smoothTempSpace(sample, config);
    finalizeSample(sample, config);
}
