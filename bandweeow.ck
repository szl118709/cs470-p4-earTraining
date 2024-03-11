class BandWeeowVoice extends VoiceBankVoice
{
    // override
    0.5 => gainAtZeroVelocity;
    0.2 => highCutoffSensitivity;
    -0.5 => lowCutoffSensitivity;
    
    1 => int unison;

    float myFreqWaver;
    BPF bpf => adsr;
    SawOsc osc1[unison];
 
    // osc 1: sinosc +0c, 100% volume
    for( int i; i < unison; i++ )
    {
        1.0 / unison => osc1[i].gain;
        osc1[i] => bpf;
    }
    
    
    TriOsc lfo1 => Envelope lfo1env => blackhole;
    480::ms => lfo1env.duration;
    7.9 => lfo1.freq;
    fun void DoLFO1()
    {
        while( true )
        {
            // TODO scale and hook up
            0.005 * lfo1env.last() + 1 => myFreqWaver;
            5::ms => now;
        }
    }
    
    fun void ResetLFO1()
    {
        0 => lfo1env.value;
        1 => lfo1env.target;
        -0.25 => lfo1.phase;
    }
    
    spork ~ DoLFO1();

    
    
    fun void sync()
    {
        for( int i; i < unison; i++ )
        {
            // TODO: necessary?
            // 0 => osc1[i].phase => osc2[i].phase;
        }
        ResetLFO1();
    }
    
    
    

    fun float cutoffToHz( float cutoff )
    {
        return Math.min( Std.scalef( Math.pow( Std.clampf( cutoff, 0, 1 ), 3 ), 0, 1, myFreq * 0.5, 13000 ), 13000 );
    }
    
    // LPF cutoff envelope is AD with A = 0.92ms, D = 170ms
    // but actually the max cutoff is 0.17 + (0.82-0.17 * current velocity)
    ADSR filterEnv => blackhole;
    0.999 => float filterSustain;
    filterEnv.set( 1300::ms, 900::ms, filterSustain, 10000::ms );
    
    Step goalCutoff => OnePole actualCutoff => blackhole;
    // defaults
    1000 => goalCutoff.next;
    0.998 => actualCutoff.pole;
    
    fun void triggerFilterEnv()
    {
        // reset
        0 => filterEnv.value;
        filterSustain => filterEnv.sustainLevel;
        
        Math.pow( myVelocity, 1.6 ) => float v;
        0.18 + 0.74 * v => float minCutoff;
        // higher cutoff at higher pitch and at higher velocity
        Std.scalef( v, 0, 1, -0.28, -0.54 ) => float cutoffDiff;
        minCutoff => float currentCutoff;
                
        filterEnv.keyOn( 1 );
        
        5::ms => dur delta;
                        
        while( true )
        {
            // set
            minCutoff + cutoffDiff * Math.pow( filterEnv.value(), 0.25 ) => currentCutoff;
            currentCutoff + myCutoff => this.cutoffToHz => goalCutoff.next;
                                    
            // wait
            delta => now;
            // if someone told me to exit then pay attention
            me.yield();
        }        
    }
    null @=> Shred triggerFilterEnvShred;
    
    fun void endFilterEnv()
    {
        filterEnv.keyOff( 1 );
    }

    
    // bpf is not resonant
    0.5 => bpf.Q;
    
    // then ADSR on volume
    300::ms => rTime;
    0.4 => float adsrSustain;
    adsr.set( 0::ms, 300::ms, adsrSustain, rTime );
    
    
    // osc1: freq
    fun void applyFreqs()
    {
        float f1, f2;
        while( true )
        {
            
            actualCutoff.last() => bpf.freq;
            
            // myFreq
            myFreq * myFreqWaver => f1;
            
            for( int i; i < unison; i++ )
            {
                f1 => osc1[i].freq;
            }
            
            1::ms => now;
        }
    }
    spork ~ applyFreqs();

        
    // trigger note on
    true => int avail;
    fun void noteOn()
    {
        // sustain level
        Std.scalef( myVelocity, 0, 1, 1, 2 ) * adsrSustain => adsr.sustainLevel;

        // sync
        sync();
        if( triggerFilterEnvShred != null ) { triggerFilterEnvShred.exit(); }
        spork ~ this.triggerFilterEnv() @=> triggerFilterEnvShred;   
        // key on, delayed to avoid click
        spork ~ DelayedStart();
        false => avail;
    }

    fun void DelayedStart()
    {
        4::ms => now;
        adsr.keyOn( 1 );

    }
    
    // trigger note off
    fun void noteOff()
    {
        adsr.keyOff( 1 );
        endFilterEnv();
        spork ~ DelayedEnd();
    }
    
    fun void DelayedEnd()
    {
        // we will be cut off exactly at rTime
        // so mark self available 1 sample before that ~_~
        rTime - samp => now;
        true => avail;
    }
    
    // need to override because I messed with the start of the note
    // so now if it's in the 4ms between note start and
    // adsr start, the voice will get taken
    fun int available()
    {
        return avail;
    }
    
}


public class BandWeeow extends VoiceBank
{
    8 => numVoices;
    
    // voices
    BandWeeowVoice myVoices[numVoices];
    // assign to superclass
    v.size( myVoices.size() );
    for( int i; i < myVoices.size(); i++ )
    {
        myVoices[i] @=> v[i];
    }
    // connect
    init( true );
}

