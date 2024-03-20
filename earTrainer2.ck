// tester
// SinOsc osc => dac; 1::second => now;

//------------------------------------------------------------------------------
// variables
//------------------------------------------------------------------------------
global float SLIDER1;
global float SLIDER2;
global float SLIDER3;
global float SLIDER4;
global float DIFF;
global int PLAYRADIO;

// things that are the same for ref and user
0.1 => float velocity;

0 => float reverb_min;
0.3 => float reverb_range;

1000 => float lpf_min;
15000 => float lpf_range;

1 => float compress_min;
9 => float compress_range;

me.dir() + "93.wav" => string filename;


//------------------------------------------------------------------------------
// ref
//------------------------------------------------------------------------------
// sound file to load; me.dir() returns location of this file

// the patch 
SndBuf buf_ref => LPF l_ref => JCRev rev_ref => Dyno d_ref => Pan2 pan_ref => dac;
buf_ref => l_ref => rev_ref => d_ref => FFT fft1;
// load the file
filename => buf_ref.read;
velocity => buf_ref.gain;
d_ref.compress();
d_ref.thresh(0.3);

fun void ApplyGlobals_ref()
{
    while( true )
    {
        if (PLAYRADIO == 0) { // play both; play ref on the left
            -1 => pan_ref.pan;
            velocity => buf_ref.gain;
        }
        else if (PLAYRADIO == 1) { // play ref
            0 => pan_ref.pan;
            velocity => buf_ref.gain;
        } 
        else if (PLAYRADIO == 2) { // play user
            0 => buf_ref.gain;
        }

        10::ms => now;
    }
}
spork ~ ApplyGlobals_ref();

fun void loop_ref() {
    while( true )
    {
        Math.random2f(reverb_min, reverb_min + reverb_range) => float reverb_ref;
        Math.random2f(lpf_min, lpf_min + lpf_range) => float lowpass_ref;
        Math.random2f(compress_min, compress_min + compress_range) => float compress_ref;

        reverb_ref => rev_ref.mix;
        lowpass_ref => l_ref.freq;
        compress_ref => d_ref.ratio;

        0 => buf_ref.pos;
        buf_ref.samples()::samp => now;
    }
}
spork ~loop_ref();


//------------------------------------------------------------------------------
// user
//------------------------------------------------------------------------------
// the patch 
SndBuf buf_user => LPF l_user => JCRev rev_user => Dyno d_user => Pan2 pan_user => dac;
buf_user => l_user => rev_user => d_user => FFT fft2;
// load the file
filename => buf_user.read;
velocity => buf_user.gain;
d_user.compress();
d_user.thresh(0.3);

fun void ApplyGlobals_user()
{
    while( true )
    {
        reverb_min + reverb_range * SLIDER2 => rev_user.mix;
        lpf_min + lpf_range * SLIDER3 => l_user.freq;
        compress_min + compress_range * SLIDER4 => d_user.ratio;

        if (PLAYRADIO == 0) { // play both; play user on the right
            1 => pan_user.pan;
            velocity => buf_user.gain;
        }
        else if (PLAYRADIO == 1) { // play ref
            0 => buf_user.gain;
        } 
        else if (PLAYRADIO == 2) { // play user
            0 => pan_user.pan;
            velocity => buf_user.gain;
        }

        10::ms => now;
    }
}
spork ~ ApplyGlobals_user();

fun void loop_user() {
    while( true )
    {
        0 => buf_user.pos;
        buf_user.samples()::samp => now;
    }
}
spork ~loop_user();


//------------------------------------------------------------------------------
// analyze
//------------------------------------------------------------------------------
FeatureCollector combo1 => blackhole;
FeatureCollector combo2 => blackhole;
fft1 =^ Centroid centroid1 =^ combo1;
fft2 =^ Centroid centroid2 =^ combo2;
fft1 =^ Flux flux1 =^ combo1;
fft2 =^ Flux flux2 =^ combo2;
fft1 =^ RMS rms1 =^ combo1;
fft2 =^ RMS rms2 =^ combo2;
fft1 =^ MFCC mfcc1 =^ combo1;
fft2 =^ MFCC mfcc2 =^ combo2;

// set FFT size
4096 => fft1.size;
4096 => fft2.size;
// set window type and size
Windowing.hann(fft1.size()) => fft1.window;
Windowing.hann(fft2.size()) => fft2.window;
20 => mfcc1.numCoeffs;
20 => mfcc2.numCoeffs;
10 => mfcc1.numFilters;
10 => mfcc2.numFilters;

combo1.upchuck();
combo2.upchuck();

// stuff that only need to be extracted once
combo1.fvals().size() => int NUM_DIMENSIONS; // should match up
// our hop size (how often to perform analysis)
(fft1.size()/2)::samp => dur HOP;
// how many frames to aggregate before averaging?
// (this does not need to match extraction; might play with this number)
4 => int NUM_FRAMES;
// how much time to aggregate features for each file
fft1.size()::samp * NUM_FRAMES => dur EXTRACT_TIME;

// use this for new input
float features1[NUM_FRAMES][NUM_DIMENSIONS];
float features2[NUM_FRAMES][NUM_DIMENSIONS];
// average values of coefficients across frames
float featureMean1[NUM_DIMENSIONS];
float featureMean2[NUM_DIMENSIONS];

//------------------------------------------------------------------------------
// real-time similarity comparison loop
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
        combo1.upchuck();  
        combo2.upchuck(); 
        // get features
        for( int d; d < NUM_DIMENSIONS; d++) 
        {
            // store them in current frame
            combo1.fval(d) => features1[frame][d];
            combo2.fval(d) => features2[frame][d];
        }
        // advance time
        HOP => now;
    }
    
    // compute means for each coefficient across frames
    for( int d; d < NUM_DIMENSIONS; d++ )
    {
        // zero out
        0.0 => featureMean1[d];
        0.0 => featureMean2[d];
        0.0 => DIFF;
        // loop over frames
        for( int j; j < NUM_FRAMES; j++ )
        {
            // add
            features1[j][d] +=> featureMean1[d];
            features2[j][d] +=> featureMean2[d];
        }
        // average
        NUM_FRAMES /=> featureMean1[d];
        NUM_FRAMES /=> featureMean2[d];
        (featureMean1[d] - featureMean2[d]) * (featureMean1[d] - featureMean2[d]) +=> DIFF;
        <<<d>>>;
        <<< featureMean1[d] >>>;
        <<< featureMean2[d] >>>;
        <<< DIFF >>>;
    }
}


while( true ) {
    1::second => now;
}
