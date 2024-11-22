import("stdfaust.lib");

declare author "Jeremy WY";
declare copyright "GRAME";
declare license "LGPL with exception";

freq = hslider("freq", 440, 20, 2000, 0.01);
gate = button("gate");
gain = hslider("gain", 0.5, 0, 1, 0.001) : si.polySmooth(gate, 0.999, 64);

// Feedback function 
fb(ops, mul) = ops ~ mean *(mul) 
with {
    mean(x) = (x + x') / 2;
};

// Operator definition with modulation input
operator(i, modInput) = 
    (phaseMod(freq+freqEnv, fbAmt, modInput) * en.adsre(a,d,s,r,gate)) * amp
with {
    // Operator parameters 
    f = hslider("f%i", 1, 0.001, 12, 0.001);
    a = hslider("a%i", 0.01, 0.001, 4, 0.001);
    d = hslider("d%i", 0.4, 0.001, 4, 0.001);
    s = hslider("s%i", 0.5, 0, 1, 0.01);
    r = hslider("r%i", 2, 0.001, 4, 0.001);
    amp = hslider("amp%i", 0.1, 0, 1, 0.01);
    fa = hslider("fa%i", 0.001, 0.001, 4, 0.001);
    fd = hslider("fd%i", 0.1, 0.001, 4, 0.001);
    fs = hslider("fs%i", 0, 0, 1, 0.01);
    fr = hslider("fr%i", 0.1, 0.001, 4, 0.001);
    fbAmt = hslider("fbAmt%i", 0, 0, 18, 0.1);
    freqDepth = hslider("freqDepth%i", 200, 0, 1400, 0.1);
    
    // Frequency envelope
    freqEnv = en.adsre(fa,fd,fs,fr,gate) * freqDepth;
    
    // Oscillator with feedback and modulation
    phaseMod(f, fb, modd) = modd : op(f) ~ *(fb)
    with {
        op(f, mod) = _, mod : + : os.oscp(f) * 0.5;

        fbFeedback(x, mul) = x ~ mean * mul 
        with {
            mean(x) = (x + x') / 2;
        };
    };
};


process = operator(1, (os.osc(freq*12) * 0.01) + (os.osc(freq*3.21) * 0.1) ) <: _, _;