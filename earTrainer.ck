// tester
// SinOsc osc => dac; 1::second => now;

// ----- variables -----
global float SLIDER1;
global float SLIDER2;
global float SLIDER3;
global float SLIDER4;

// things that are the same for ref and user
0.3 => float velocity;
48 => int pitch_min;
37 => int pitch_range; // range = [36, 96]
0 => float reverb_min;
0.5 => float reverb_range; // range = [0, 0.5]
500 => float lpf_min;
15000 => float lpf_range; // range = [500, 15500]
0.2 => float cutoff_min;
0.8 => float cutoff_range;


// ----- ref -----
BandWeeow b_ref => LPF l_ref => JCRev rev_ref => dac.left;
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


// ----- user -----
BandWeeow b => LPF l => JCRev rev => dac.right;
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


// ----- play -----
while( true ) {
    1::second => now;
}
