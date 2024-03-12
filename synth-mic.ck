//------------------------------------------------------------------------------
// name: mosaic-synth-mic.ck (v1.3)
// desc: basic structure for a feature-based synthesizer
//       this particular version uses microphone as live input
//
// version: need chuck version 1.4.2.1 or higher
// sorting: part of ChAI (ChucK for AI)
//
// USAGE: run with INPUT model file
//        > chuck mosaic-synth-mic.ck:file
//
// uncomment the next line to learn more about the KNN2 object:
// KNN2.help();
//
// date: Spring 2023
// authors: Ge Wang (https://ccrma.stanford.edu/~ge/)
//          Yikai Li
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// unit analyzer network: *** this must match the features in the features file
//------------------------------------------------------------------------------
// audio input into a FFT
SinOsc osc => FFT fft => dac;
// a thing for collecting multiple features into one vector
FeatureCollector combo => blackhole;
// add spectral feature: Centroid
fft =^ Centroid centroid =^ combo;
// add spectral feature: Flux
fft =^ Flux flux =^ combo;
// add spectral feature: RMS
fft =^ RMS rms =^ combo;
// add spectral feature: MFCC
fft =^ MFCC mfcc =^ combo;


//-----------------------------------------------------------------------------
// setting analysis parameters -- also should match what was used during extration
//-----------------------------------------------------------------------------
// set number of coefficients in MFCC (how many we get out)
// 13 is a commonly used value; using less here for printing
20 => mfcc.numCoeffs;
// set number of mel filters in MFCC
10 => mfcc.numFilters;

// do one .upchuck() so FeatureCollector knows how many total dimension
combo.upchuck();
// get number of total feature dimensions
combo.fvals().size() => int NUM_DIMENSIONS;

// set FFT size
4096 => fft.size;
// set window type and size
Windowing.hann(fft.size()) => fft.window;
// our hop size (how often to perform analysis)
(fft.size()/2)::samp => dur HOP;
// how many frames to aggregate before averaging?
// (this does not need to match extraction; might play with this number)
4 => int NUM_FRAMES;
// how much time to aggregate features for each file
fft.size()::samp * NUM_FRAMES => dur EXTRACT_TIME;


// use this for new input
float features[NUM_FRAMES][NUM_DIMENSIONS];
// average values of coefficients across frames
float featureMean[NUM_DIMENSIONS];

//------------------------------------------------------------------------------
// real-time similarity retrieval loop
//------------------------------------------------------------------------------
while( true )
{
    // aggregate features over a period of time
    for( int frame; frame < NUM_FRAMES; frame++ )
    {
        //-------------------------------------------------------------
        // a single upchuck() will trigger analysis on everything
        // connected upstream from combo via the upchuck operator (=^)
        // the total number of output dimensions is the sum of
        // dimensions of all the connected unit analyzers
        //-------------------------------------------------------------
        combo.upchuck();  
        // get features
        for( int d; d < NUM_DIMENSIONS; d++) 
        {
            // store them in current frame
            combo.fval(d) => features[frame][d];
        }
        // advance time
        HOP => now;
    }
    
    // compute means for each coefficient across frames
    for( int d; d < NUM_DIMENSIONS; d++ )
    {
        // zero out
        0.0 => featureMean[d];
        // loop over frames
        for( int j; j < NUM_FRAMES; j++ )
        {
            // add
            features[j][d] +=> featureMean[d];
        }
        // average
        NUM_FRAMES /=> featureMean[d];
        <<< featureMean[d], d>>>;
    }
    
}
//------------------------------------------------------------------------------
// end of real-time similiarity retrieval loop
//------------------------------------------------------------------------------

while (true) {
    1::second => now;
}