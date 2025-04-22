//Copyright 2023 Johannes Klatt

//This file is part of libESPER.
//libESPER is free software: you can redistribute it and /or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or any later version.
//libESPER is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//You should have received a copy of the GNU General Public License along with Nova - Vox.If not, see <https://www.gnu.org/licenses/>.

#include "ESPER/pitchCalcFallback.h"

#include <malloc.h>
#include <math.h>
#include "util.h"
#include "interpolation.h"

//defines a struct for a marker candidate in the pitch calculation process.
//attributes:
// - position: the position of the zero crossing in the signal.
// - previous: a pointer to the previous marker candidate in the pitch graph. Filled using Dijkstra's algorithm.
// - distance: the distance from the nearest root marker candidate to this marker candidate in the pitch graph. Filled using Dijkstra's algorithm.
// - isRoot: a flag indicating whether this marker candidate is a root marker candidate. Root marker candidates have no predecessors in the pitch graph.
// - isLeaf: a flag indicating whether this marker candidate is a leaf marker candidate. Leaf marker candidates have no successors in the pitch graph.
typedef struct
{
    unsigned int position;
	void* previous;
	float distance;
	int isRoot;
	int isLeaf;
} MarkerCandidate;

//uses a momentum function to smooth the waveform of a sample.
//this is done to remove high-frequency noise and lower the effect of volume changes by dampening regions with high audio volume.
float* createSmoothedWave(cSample* sample)
{
	float* smoothedWave = (float*)malloc(sample->config.length * sizeof(float));
	float x = 0;
	float v = 0;
	float a = 0;
	for (int i = 0; i < sample->config.length; i++) {
		a = *(sample->waveform + i) - 0.1 * x - 0.1 * v;
		v += a;
		x += v;
		*(smoothedWave + i) = x;
	}
	return smoothedWave;
}

//returns an array of upwards zero crossings in a signal.
dynIntArray getZeroTransitions(float* signal, int length)
{
	dynIntArray zeroTransitions;
	dynIntArray_init(&zeroTransitions);
	for (int i = 1; i < length; i++) {
		if (*(signal + i - 1) < 0 && *(signal + i) >= 0) {
			dynIntArray_append(&zeroTransitions, i);
		}
	}
	return zeroTransitions;
}

//converts an array of zero crossings to a corresponding array of MarkerCandidate structs.
MarkerCandidate* createMarkerCandidates(dynIntArray zeroTransitions, unsigned int batchSize, unsigned int lowerLimit, unsigned int length)
{
	int markerCandidateLength = zeroTransitions.length;
	MarkerCandidate* markerCandidates = (MarkerCandidate*)malloc(zeroTransitions.length * sizeof(MarkerCandidate));
	for (int i = 0; i < zeroTransitions.length; i++) {
		(markerCandidates + i)->position = zeroTransitions.content[i];
		(markerCandidates + i)->previous = NULL;
		(markerCandidates + i)->distance = 0;
		if (zeroTransitions.content[i] < batchSize || i == 0) {
			(markerCandidates + i)->isRoot = 1;
		}
		else
		{
			(markerCandidates + i)->isRoot = 0;
		}
		if (zeroTransitions.content[i] >= length - batchSize || i == zeroTransitions.length - 1) {
			(markerCandidates + i)->isLeaf = 1;
		}
		else
		{
			(markerCandidates + i)->isLeaf = 0;
		}
	}
	return markerCandidates;
}

//builds a pitch graph using an adapted version of Dijkstra's algorithm.
//The nodes of the graph are the zero crossings in the signal.
//An edge is assumed to exist between two nodes if their distance in signal space is above the lowerLimit argument, but below the batchSize argument.
//Edges always point from a node to a node with a higher index, making the graph a directed acyclic graph.
//If a node has no outgoing edges according to these rules, an edge connecting it to the next node in signal space is assumed to exist.
//The weight of each edge is calculated through two objectives:
// - minimizing the squared difference between the signal values in the vicinity of the two nodes
// - maximizing the amplitude of the assumed f0 component of the signal. This is achieved by multiplying the signal in the vicinity of the first node with a sine wave of the frequency corresponding to the distance between the two nodes.
//The first term ensures that the pitch period is not underestimated, since the similarity between different parts of the same signal period is low.
//The second term prevents the pitch period from being overestimated as a multiple of the real pitch period, since multiple repetitions of the same signal period in sequence do not have a frequency component matching the assumed f0.
//
//Based on this, a modified version of Dijkstra's algorithm is used to find the shortest path from any root node to all other nodes in the graph.
//The modification is simple: Instead of starting from a single root, multiple are specified, each with distance 0 and no predecessors. The algorithm then proceeds as usual.
//Additionally, since we already know an ordering of the nodes, all nodes can be evaluated in sequence, omitting the open set and closed set arrays used in the original algorithm.
void buildPitchGraph(MarkerCandidate* markerCandidates, int markerCandidateLength, unsigned int batchSize, unsigned int lowerLimit, cSample* sample, float* smoothedWave, engineCfg config)
{
	for (int i = 0; i < markerCandidateLength; i++)
	{
		if ((markerCandidates + i)->isRoot)
		{
			continue;
		}
		int isValid = 0;
		for (int j = 1; j <= i; j++)
		{
			unsigned int positionI = (markerCandidates + i)->position;
			unsigned int positionJ = (markerCandidates + i - j)->position;
			unsigned int delta = positionI - positionJ;
			if (delta < lowerLimit)
			{
				continue;
			}
			if ((delta > batchSize) && isValid == 1)
			{
				break;
			}
			float bias;
			if (sample->config.expectedPitch == 0)
			{
				bias = 1.;
			}
			else
			{
				bias = fabsf(delta - (float)config.sampleRate / (float)sample->config.expectedPitch);
			}
			double newError = 0;
			double contrast = 0;
			if (positionJ < delta)
			{
				for (int k = 0; k < delta; k++)
				{
					newError += powf(*(smoothedWave + positionI + k) - *(smoothedWave + positionJ + k), 2.) * bias;
					contrast += *(smoothedWave + positionI + k) * sinf(2. * pi * k / delta);
				}
			}
			else if (positionI >= sample->config.length - delta)
			{
				for (int k = 0; k < delta; k++)
				{
					newError += powf(*(smoothedWave + positionI - k) - *(smoothedWave + positionJ - k), 2.) * bias;
					contrast += *(smoothedWave + positionI - k) * sinf(2. * pi * k / delta);
				}
			}
			else
			{
				for (int k = 0; k < delta; k++)
				{
					newError += powf(*(smoothedWave + positionI - delta / 2 + k) - *(smoothedWave + positionJ - delta / 2 + k), 2.) * bias;
					contrast += *(smoothedWave + positionI - delta / 2 + k) * sinf(2. * pi * k / delta);
				}
			}

			if ((markerCandidates + i - j)->distance + newError / powf(contrast, 2.) < (markerCandidates + i)->distance || (markerCandidates + i)->distance == 0) {
				(markerCandidates + i)->distance = (markerCandidates + i - j)->distance + newError / powf(contrast, 2.);
				(markerCandidates + i)->previous = markerCandidates + i - j;
			}
			isValid = 1;
		}
	}
}

//takes a pitch graph, given as an array of MarkerCandidate structs, and fills an array of pitch markers with the positions of the zero crossings corresponding to the optimal path through the graph.
//The optimal path is determined by finding the leaf node with the lowest distance to any root node, and then following the previous pointers.
//Since this gives the path in reverse order, the zeroTransitions array is reused to intermittently store the reversed path, before copying it to the pitchMarkers array in the correct order.
void fillPitchMarkers(dynIntArray zeroTransitions, MarkerCandidate* markerCandidates, int markerCandidateLength, cSample* sample)
{
	zeroTransitions.length = 0;
	MarkerCandidate* currentBase = markerCandidates + markerCandidateLength - 1;
	MarkerCandidate* current = currentBase;
	while (currentBase->isLeaf)
	{
		if (currentBase->distance < current->distance)
		{
			current = currentBase;
		}
		currentBase--;
	}
	while (current->previous != NULL)
	{
		dynIntArray_append(&zeroTransitions, current->position);
		current = current->previous;
	}
	sample->config.markerLength = zeroTransitions.length;
	for (int i = 0; i < zeroTransitions.length; i++) {
		*(sample->pitchMarkers + i) = zeroTransitions.content[zeroTransitions.length - i - 1];
	}
}

void checkMarkerValidity(cSample* sample, engineCfg config)
{
	//first and last marker are always valid
	*(sample->pitchMarkerValidity) = 1;
	*(sample->pitchMarkerValidity + sample->config.markerLength - 2) = 1;
	for (int i = 1; i < sample->config.markerLength - 2; i++)
	{
		int sectionSize = *(sample->pitchMarkers + i + 1) - *(sample->pitchMarkers + i);
		int previousSize = *(sample->pitchMarkers + i) - *(sample->pitchMarkers + i - 1);
		int nextSize = *(sample->pitchMarkers + i + 2) - *(sample->pitchMarkers + i + 1);

		if (previousSize <= sectionSize + 2 || nextSize <= sectionSize + 2)
		{
			*(sample->pitchMarkerValidity + i) = 1;
			continue;
		}

		float validError = 0;

		float* windowSpace = (float*)malloc(sectionSize * sizeof(float));
		for (int j = 0; j < sectionSize; j++)
		{
			*(windowSpace + j) = j;
		}
		float* previousSpace = (float*)malloc(previousSize * sizeof(float));
		for (int j = 0; j < previousSize; j++)
		{
			*(previousSpace + j) = j * (float)sectionSize / (float)previousSize;
		}
		float* nextSpace = (float*)malloc(nextSize * sizeof(float));
		for (int j = 0; j < nextSize; j++)
		{
			*(nextSpace + j) = j * (float)sectionSize / (float)nextSize;
		}
		float* window = sample->waveform + *(sample->pitchMarkers + i);
		float* previous = sample->waveform + *(sample->pitchMarkers + i - 1);
		float* next = sample->waveform + *(sample->pitchMarkers + i + 2) - sectionSize;
		float* previous_interp = interp(previousSpace, previous, windowSpace, previousSize, sectionSize);
		float* next_interp = interp(nextSpace, next, windowSpace, nextSize, sectionSize);
		for (int j = 0; j < sectionSize; j++)
		{
			validError += powf((*(window + j) - (*(previous_interp + j) + *(next_interp + j)) / 2.), 2.);
		}
		free(windowSpace);
		free(previousSpace);
		free(nextSpace);
		free(previous_interp);
		free(next_interp);

		float invalidError = 0.;
		for (int j = 0; j < sectionSize; j++)
		{
			float alternative = *(sample->waveform + *(sample->pitchMarkers + i - 1) + j) - (*(sample->waveform + *(sample->pitchMarkers + i + 2) - sectionSize + j));
			invalidError += powf(alternative / 2., 2.);
		}
		if (invalidError < validError)
		{
			*(sample->pitchMarkerValidity + i) = 0;
		}
		else
		{
			*(sample->pitchMarkerValidity + i) = 1;
		}
	}
}

int getValidPitchDelta(cSample* sample, int index)
{
	if (*(sample->pitchMarkerValidity + index) == 1)
	{
		return *(sample->pitchMarkers + index + 1) - *(sample->pitchMarkers + index);
	}
	else
	{
		//adjacent markers are never both invalid, since an invalid marker requires two larger adjacent marker distances
		int nextDelta = *(sample->pitchMarkers + index + 2) - *(sample->pitchMarkers + index + 1);
		int previousDelta = *(sample->pitchMarkers + index) - *(sample->pitchMarkers + index - 1);
		return (nextDelta + previousDelta) / 2;
	}
}

//fills an array of pitch deltas with the differences between the pitch markers.
//pitch markers represent the pitch curve in pitch-synchronous form, while the pitch deltas represent the pitch at constant time intervals.
//Therefore, the pitch deltas are calculated by finding the pitch markers closest to the current time interval, and taking the difference between them.
//This is a sampling operation, so there is no guarantee all pitch markers will be used. Likewise, in extreme cases, the same markers may also be used several times.
void fillPitchDeltas(cSample* sample, engineCfg config)
{
	unsigned int cursor = 0;
	for (int i = 0; i < sample->config.batches; i++) {
		while ((sample->pitchMarkers[cursor] <= i * config.batchSize) && (cursor < sample->config.markerLength)) {
			cursor++;
		}
		if (cursor == 0) {
			*(sample->pitchDeltas + i) = sample->pitchMarkers[cursor + 1] - sample->pitchMarkers[cursor];
		}
		else if (cursor == sample->config.markerLength) {
			*(sample->pitchDeltas + i) = sample->pitchMarkers[cursor - 1] - sample->pitchMarkers[cursor - 2];
		}
		else
		{
			*(sample->pitchDeltas + i) = getValidPitchDelta(sample, cursor - 1);
		}
	}
}

//master function for pitch calculation.
//Fills the pitchMarkers and pitchDeltas arrays of a sample, representing the pitch in pitych-synchronous and constant time intervals, respectively, and calculates the median pitch.
//The name "fallback" is left over from a previous version, where it was only used if pitch calculation using torchaudio failed.
//It is now the only pitch calculation method, as other methods cannot provide the pitch-synchronous representation required by other parts of the library with sufficient accuracy.
void LIBESPER_CDECL pitchCalcFallback(cSample* sample, engineCfg config) {

	//limits for pitch graph edge creation
	unsigned int batchSize;
	unsigned int lowerLimit;
	if (sample->config.expectedPitch == 0) {
		batchSize = config.tripleBatchSize;
		lowerLimit = config.sampleRate / 1000;
	}
	else
	{
		batchSize = (int)((1. + sample->config.searchRange) * (float)config.sampleRate / (float)sample->config.expectedPitch);
		if (batchSize > config.tripleBatchSize)
		{
			batchSize = config.tripleBatchSize;
		}
		lowerLimit = (int)((1. - sample->config.searchRange) * (float)config.sampleRate / (float)sample->config.expectedPitch);
		if (lowerLimit < config.sampleRate / 1000)
		{
			lowerLimit = config.sampleRate / 1000;
		}
	}

	float* smoothedWave = createSmoothedWave(sample);
	dynIntArray zeroTransitions = getZeroTransitions(smoothedWave, sample->config.length);
	int markerCandidateLength = zeroTransitions.length;
	if (markerCandidateLength == 0)
	{
		for (int i = 0; i < sample->config.batches; i++)
		{
			*(sample->pitchDeltas + i) = 100;
		}
		return;
	}
	MarkerCandidate* markerCandidates = createMarkerCandidates(zeroTransitions, batchSize, lowerLimit, sample->config.length);
	buildPitchGraph(markerCandidates, markerCandidateLength, batchSize, lowerLimit, sample, smoothedWave, config);
	fillPitchMarkers(zeroTransitions, markerCandidates, markerCandidateLength, sample);
	dynIntArray_dealloc(&zeroTransitions);
	free(markerCandidates);
	free(smoothedWave);
	if (sample->config.markerLength < 2)
	{
		for (int i = 0; i < sample->config.batches; i++)
		{
			*(sample->pitchDeltas + i) = 100;
		}
		return;
	}
	checkMarkerValidity(sample, config);
	fillPitchDeltas(sample, config);
	sample->config.pitch = median(sample->pitchDeltas, sample->config.pitchLength);
}
