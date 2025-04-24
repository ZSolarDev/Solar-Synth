#pragma once

static engineCfg cfg = {
        44100,                  // sampleRate (Hz)
        230,                    // tickRate
        192,                    // batchSize
        576,                    // tripleBatchSize
        288,                    // halfTripleBatchSize
        64,                     // nHarmonics
        33,                     // halfHarmonics
        355,                    // frameSize
        0.05f                   // breCompPremul
};