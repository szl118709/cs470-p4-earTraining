SinOsc s => Delay d => ABSaturator sat => dac;

0.5::second => d.max => d.delay;

0.5 => bc.gain;
32 => bc.bits;
64 => bc.downsampleFactor;

<<< "bits:", bc.bits(), "downsampling:", bc.downsampleFactor() >>>;

while(true)
{
    1::second => now;
}
