// things that are the same for ref and user
0.5 => float VELOCITY;

// ----- ref -----
BandWeeow b_ref => LPF l_ref => JCRev rev_ref => dac.left;
0.6 => b_ref.gain;
0.05 => rev_ref.mix;
15000 => l_ref.freq;

// knobs
global float gReverb_ref;
global float gCutoff_ref;
5000 => global float gLowpass_ref;

fun void ApplyGlobals_ref()
{
    while( true )
    {
        10::ms => now;
        gReverb_ref => rev_ref.mix;
        gLowpass_ref => l_ref.freq;
        gCutoff_ref => b_ref.cutoff;
    }
}
spork ~ ApplyGlobals_ref();
b_ref.noteOn( 60, VELOCITY );
// ----- end ref -----


// ----- user -----
BandWeeow b => LPF l => JCRev rev => dac.right;
0.6 => b.gain;
0.05 => rev.mix;
15000 => l.freq;

// knobs
global float gReverb;
global float gCutoff;
5000 => global float gLowpass;

fun void ApplyGlobals()
{
    while( true )
    {
        10::ms => now;
        gReverb => rev.mix;
        gLowpass => l.freq;
        gCutoff => b.cutoff;
    }
}
spork ~ ApplyGlobals();
// end knobs


MidiIn min;
MidiMsg msg;
global int midiCommand;
global int midiNote;
global int midiVelocity;

if( !min.open( 0 ) ) me.exit();

fun void NoteOn( int m, int v )
{
    v * 1.0 / 128 => float velocity;
    b.noteOn( m, VELOCITY );
    <<< "on", m, v >>>;
}


fun void NoteOff( int m )
{
    spork ~ b.noteOff( m );
    //<<< "off", m >>>;
}


while( true )
{
    min => now;
    min.recv(msg);
    msg.data1 => midiCommand;
    msg.data2 => midiNote;
    msg.data3 =>midiVelocity;

    if( midiCommand >= 144 && midiCommand < 160 )
    {
        if( midiVelocity > 0 )
        {
            NoteOn( midiNote, midiVelocity );
        }
        else
        {
            NoteOff( midiNote );
        }
    }
    else if( midiCommand >= 128 && midiCommand < 144 )
    {
        NoteOff( midiNote );
    }
    else
    {
        // <<< "unknown midi command:", midiCommand, midiNote, midiVelocity >>>;
    }
}