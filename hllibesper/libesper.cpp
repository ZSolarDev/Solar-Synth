#define HL_NAME(n) libesper_##n

#include "esper.h"
#include <hl.h>
#include <iostream>
#include <math.h>

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
HL_PRIM int HL_NAME(get_sample_rate)() {
    return cfg.sampleRate;
}
DEFINE_PRIM(_I32, get_sample_rate);
HL_PRIM void HL_NAME(set_sample_rate)(int sampleRate) {
    cfg.sampleRate = sampleRate;
}
DEFINE_PRIM(_VOID, set_sample_rate, _I32);


HL_PRIM int HL_NAME(get_tick_rate)() {
    return cfg.tickRate;
}
DEFINE_PRIM(_I32, get_tick_rate);
HL_PRIM void HL_NAME(set_tick_rate)(int tickRate) {
    cfg.tickRate = tickRate;
}
DEFINE_PRIM(_VOID, set_tick_rate, _I32);


HL_PRIM int HL_NAME(get_batch_size)() {
    return cfg.batchSize;
}
DEFINE_PRIM(_I32, get_batch_size);
HL_PRIM void HL_NAME(set_batch_size)(int batchSize) {
    cfg.batchSize = batchSize;
}
DEFINE_PRIM(_VOID, set_batch_size, _I32);


HL_PRIM int HL_NAME(get_triple_batch_size)() {
    return cfg.tripleBatchSize;
}
DEFINE_PRIM(_I32, get_triple_batch_size);
HL_PRIM void HL_NAME(set_triple_batch_size)(int tripleBatchSize) {
    cfg.tripleBatchSize = tripleBatchSize;
}
DEFINE_PRIM(_VOID, set_triple_batch_size, _I32);


HL_PRIM int HL_NAME(get_half_triple_batch_size)() {
    return cfg.halfTripleBatchSize;
}
DEFINE_PRIM(_I32, get_half_triple_batch_size);
HL_PRIM void HL_NAME(set_half_triple_batch_size)(int halfTripleBatchSize) {
    cfg.halfTripleBatchSize = halfTripleBatchSize;
}
DEFINE_PRIM(_VOID, set_half_triple_batch_size, _I32);


HL_PRIM int HL_NAME(getn_harmonics)() {
    return cfg.nHarmonics;
}
DEFINE_PRIM(_I32, getn_harmonics);
HL_PRIM void HL_NAME(setn_harmonics)(int nHarmonics) {
    cfg.nHarmonics = nHarmonics;
}
DEFINE_PRIM(_VOID, setn_harmonics, _I32);


HL_PRIM int HL_NAME(get_half_harmonics)() {
    return cfg.halfHarmonics;
}
DEFINE_PRIM(_I32, get_half_harmonics);
HL_PRIM void HL_NAME(set_half_harmonics)(int halfHarmonics) {
    cfg.halfHarmonics = halfHarmonics;
}
DEFINE_PRIM(_VOID, set_half_harmonics, _I32);


HL_PRIM int HL_NAME(get_frame_size)() {
    return cfg.frameSize;
}
DEFINE_PRIM(_I32, get_frame_size);
HL_PRIM void HL_NAME(set_frame_size)(int frameSize) {
    cfg.frameSize = frameSize;
}
DEFINE_PRIM(_VOID, set_frame_size, _I32);


HL_PRIM float HL_NAME(get_)() {
    return cfg.frameSize;
}
DEFINE_PRIM(_F32, get_);
HL_PRIM void HL_NAME(set_)(float frameSize) {
    cfg.frameSize = frameSize;
}
DEFINE_PRIM(_VOID, set_, _F32);