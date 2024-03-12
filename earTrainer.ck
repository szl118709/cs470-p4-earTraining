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

// things that are the same for ref and user
0.1 => float velocity;
54 => int pitch_min;
31 => int pitch_range; // range = [36, 96]
0 => float reverb_min;
0.5 => float reverb_range; // range = [0, 0.5]
500 => float lpf_min;
15000 => float lpf_range; // range = [500, 15500]
0.2 => float cutoff_min;
0.8 => float cutoff_range;


//------------------------------------------------------------------------------
// ref
//------------------------------------------------------------------------------
BandWeeow b_ref => LPF l_ref => JCRev rev_ref => dac.left;
b_ref => l_ref => rev_ref => FFT fft1;

velocity => b_ref.gain;
Math.random2(pitch_min, pitch_min + pitch_range) => global int pitch_ref; 
Math.random2f(reverb_min, reverb_min + reverb_range) => global float reverb_ref;
Math.random2f(lpf_min, lpf_min + lpf_range) => global float lowpass_ref;
Math.random2f(cutoff_min, cutoff_min + cutoff_range) => global float cutoff_ref;

fun void ApplyGlobals_ref()
{
    while( true )
    {
        10::ms => now;
        b_ref.noteOn( pitch_ref, velocity );
        reverb_ref => rev_ref.mix;
        lowpass_ref => l_ref.freq;
        cutoff_ref => b_ref.cutoff;
    }
}
spork ~ ApplyGlobals_ref();


//------------------------------------------------------------------------------
// user
//------------------------------------------------------------------------------
BandWeeow b => LPF l => JCRev rev => dac.right;
b => l => rev => FFT fft2;

velocity => b.gain;
fun void ApplyGlobals()
{
    while( true )
    {
        10::ms => now;
        b.noteOn( (pitch_min + pitch_range * SLIDER1) $ int, velocity);
        reverb_min + reverb_range * SLIDER2 => rev.mix;
        lpf_min + lpf_range * SLIDER3 => l.freq;
        cutoff_min + cutoff_range * SLIDER4 => b.cutoff;
    }
}
spork ~ ApplyGlobals();


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
