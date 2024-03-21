// tester
// SinOsc osc => dac; 1::second => now;

//------------------------------------------------------------------------------
// variables
//------------------------------------------------------------------------------
global float SLIDER1;
global float SLIDER2;
global float SLIDER3;
global float SLIDER4;
0 => global float SWITCH1;
0 => global float SWITCH2;
0 => global float SWITCH3;
0 => global float SWITCH4;
global float DIFF;
global int PLAYRADIO;

global float REF1;
global float REF2;
global float REF3;
global float REF4;



global float PRINTED;
global float TEST;

// things that are the same for ref and user
0.2 => float velocity;

100 => float lpf_min;
15000 => float lpf_range;

0 => float mod_min;
5 => float mod_range;

0 => float reverb_min;
0.2 => float reverb_range;

1 => float compress_min;
15 => float compress_range;

me.dir() + "93.wav" => string filename;


//------------------------------------------------------------------------------
// ref
//------------------------------------------------------------------------------
// sound file to load; me.dir() returns location of this file

// the patch for playing
SndBuf buf_ref => LPF l_ref => JCRev rev_ref => Dyno d_ref => Gain gl_ref => dac.left;
buf_ref => l_ref => rev_ref => d_ref => Gain gr_ref => dac.right;
3 => gl_ref.op;
3 => gr_ref.op;
Modulate mod_ref => gl_ref;
mod_ref => gr_ref;
// for analysis
SndBuf buf_ref2 => l_ref => rev_ref => d_ref => Gain const_gain_ref => FFT fft1;
mod_ref => const_gain_ref;

// load the file
filename => buf_ref.read;
filename => buf_ref2.read;

// set unchangeable parameters
velocity => buf_ref.gain;
velocity => buf_ref2.gain;
velocity => gl_ref.gain;
velocity => gr_ref.gain;
velocity => const_gain_ref.gain;
d_ref.compress();
d_ref.thresh(0.5);
mod_ref.randomGain(0);
mod_ref.vibratoGain(velocity * 4);

fun void ApplyGlobals_ref()
{
    while( true )
    {

        if (SWITCH1 == 1) {
            lpf_min + lpf_range * Math.pow(REF1, 2) => l_ref.freq;
        }
        else {
            lpf_range => l_ref.freq;
        }
        if (SWITCH2 == 1) {
            3 => gl_ref.op;
            3 => gr_ref.op;
            mod_min + mod_range * REF2 => mod_ref.vibratoRate;
        }
        else {
            1 => gl_ref.op;
            1 => gr_ref.op;
        }
        if (SWITCH3 == 1) {
            reverb_min + reverb_range * REF3 => rev_ref.mix;
        }
        else {
            0 => rev_ref.mix;
        }
        if (SWITCH4 == 1) {
            compress_min + compress_range * REF4 => d_ref.ratio;
        }
        else {
            1 => d_ref.ratio;
        }
        
        if (PLAYRADIO == 0) { // play both; play ref on the left
            velocity => gl_ref.gain;
            0 => gr_ref.gain;
        }
        else if (PLAYRADIO == 1) { // play ref
            velocity => gl_ref.gain;
            velocity => gr_ref.gain;
        } 
        else if (PLAYRADIO == 2) { // play user
            0 => gl_ref.gain;
            0 => gr_ref.gain;
        }

        10::ms => now;
    }
}
spork ~ ApplyGlobals_ref();


fun void loop_ref() {
    while( true )
    {
        // get new parameters for the new loop
        Math.randomf() => REF1;
        Math.randomf() => REF2;
        Math.randomf() => REF3;
        Math.randomf() => REF4;

        0 => PRINTED;

        // loop bus
        0 => buf_ref.pos;
        0 => buf_ref2.pos;
        buf_ref.length() => now;
    }
}
spork ~loop_ref();


//------------------------------------------------------------------------------
// user
//------------------------------------------------------------------------------
// the patch for playing
SndBuf buf_user => LPF l_user => JCRev rev_user => Dyno d_user => Gain gl_user => dac.left;
buf_user => l_user => rev_user => d_user => Gain gr_user => dac.right;
3 => gl_user.op;
3 => gr_user.op;
Modulate mod_user => gl_user;
mod_user => gr_user;
// for analysis
SndBuf buf_user2 => l_user => rev_user => d_user => Gain const_gain_user => FFT fft2;
mod_user => const_gain_user;

// load the file
filename => buf_user.read;
filename => buf_user2.read;

// set unchangeable paramters
velocity => buf_user.gain;
velocity => buf_user2.gain;
velocity => gl_user.gain;
velocity => gr_user.gain;
velocity => const_gain_user.gain;
d_user.compress();
d_user.thresh(0.5);
mod_user.randomGain(0);
mod_user.vibratoGain(velocity * 4);

fun void ApplyGlobals_user()
{
    while( true )
    {
        if (SWITCH1 == 1) {
            Math.pow(SLIDER1, 2) => float l_temp;
            lpf_min + lpf_range * l_temp => l_user.freq;
        }
        else {
            lpf_range => l_user.freq;
        }
        if (SWITCH2 == 1) {
            3 => gl_user.op;
            3 => gr_user.op;
            mod_min + SLIDER2 * mod_range => mod_user.vibratoRate;
        }
        else {
            1 => gl_user.op;
            1 => gr_user.op;
        }
        if (SWITCH3 == 1) {
            reverb_min + reverb_range * SLIDER3 => rev_user.mix;
        }
        else {
            0 => rev_user.mix;
        }
        if (SWITCH4 == 1) {
            compress_min + compress_range * SLIDER4 => d_user.ratio;
        }
        else {
            1 => d_user.ratio;
        }

        if (PLAYRADIO == 0) { // play both; play user on the right
            0 => gl_user.gain;
            velocity => gr_user.gain;
        }
        else if (PLAYRADIO == 1) { // play ref
            0 => gl_user.gain;
            0 => gr_user.gain;
        } 
        else if (PLAYRADIO == 2) { // play user
            velocity => gl_user.gain;
            velocity => gr_user.gain;
        }

        10::ms => now;
    }
}
spork ~ ApplyGlobals_user();

fun void loop_user() {
    while( true )
    {
        0 => buf_user.pos;
        0 => buf_user2.pos;
        buf_ref.length() => now;
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
