// Language -> Evaluate File
(
// s.record;
s.waitForBoot({
	Routine{
		// set the bpm
		var bpm=120;
		var scale=Scale.major;
		var octaves,octaves2;
		var notes,notes2;
		var syncopation,syncopation2;
		var t = TempoClock(8*bpm/120);
		var t2 = TempoClock(8*bpm/120);

		// define the synths
		SynthDef("jp",{ | amp=1,freq = 523.3572, mix=0.75, detune = 0.75,lpf=10 |
			var detuneCurve = { |x|
				(10028.7312891634*x.pow(11)) -
				(50818.8652045924*x.pow(10)) +
				(111363.4808729368*x.pow(9)) -
				(138150.6761080548*x.pow(8)) +
				(106649.6679158292*x.pow(7)) -
				(53046.9642751875*x.pow(6)) +
				(17019.9518580080*x.pow(5)) -
				(3425.0836591318*x.pow(4)) +
				(404.2703938388*x.pow(3)) -
				(24.1878824391*x.pow(2)) +
				(0.6717417634*x) +
				0.0030115596
			};
			var centerGain = { |x| (-0.55366 * x) + 0.99785 };
			var sideGain = { |x| (-0.73764 * x.pow(2)) + (1.2841 * x) + 0.044372 };

			var center = Mix.new(LFSaw.ar(freq, Rand()));
			var detuneFactor = freq * detuneCurve.(detune);
			var freqs = [
				(freq - (detuneFactor * 0.11002313)),
				(freq - (detuneFactor * 0.06288439)),
				(freq - (detuneFactor * 0.01952356)),
				// (freq + (detuneFactor * 0)),
				(freq + (detuneFactor * 0.01991221)),
				(freq + (detuneFactor * 0.06216538)),
				(freq + (detuneFactor * 0.10745242))
			];
			var side = Mix.fill(6, { |n|
				LFSaw.ar(freqs[n], Rand(0, 2))
			});


			var sig = (center * centerGain.(mix)) + (side * sideGain.(mix));
			sig = HPF.ar(sig ! 2, freq);
			sig = MoogLadder.ar(sig,MouseY.kr(0.5,4)*freq*lpf*3*EnvGen.kr(Env.new([LinLin.kr(freq.cpsmidi,30,100,6,0.1),1],[0.03],\exp)));
			sig = Pan2.ar(sig,2.rand-1);
			Out.ar(0,sig/7*EnvGen.ar(Env.perc(MouseX.kr(0,0.125),0.5*amp*MouseY.kr(0.25,4)),doneAction:2)*amp);
		}).send(s);
		~tape=Buffer.alloc(s,s.sampleRate*120,2);
		SynthDef("final",{
			var snd=In.ar(0,2);
			var pos,pos2;
			// var sndR = Greyhole.ar(snd);
			var sndR = Fverb.ar(snd[0],snd[1]);
			snd=SelectX.ar(0.16,[snd,sndR]);
			snd=AnalogTape.ar(snd,0.9,0.9,0.7,2);
			snd=BPeakEQ.ar(snd,32.midicps,6);
			// pos=Phasor.ar(1,1,0,BufFrames.ir(~tape));
			// pos2=Phasor.ar(1,MouseX.kr(0.98,1),0,BufFrames.ir(~tape));
			// BufWr.ar(snd,~tape,pos);
			// snd=BufRd.ar(2,~tape,pos2-256);
			SendReply.kr(Impulse.kr(10),'/mousex',MouseX.kr(0.75,1.25));
			ReplaceOut.ar(0,snd);
		}).send(s);
		s.sync;
		Synth.new("final",[],s,\addToTail);
		s.sync;

		o = OSCFunc({ |msg|
			// t.tempo=8*bpm/120*msg[3];
		}, '/mousex');
		s.sync;

		// notes=[0,2,4,0,2,4,0,2,0,2,4,0,2,4,0,2];
		// notes=notes++[-1,2,4,-1,2,4,-2,2,-1,2,4,-1,2,4,-1,2];
		// notes=notes++[-2,0,4,-2,0,4,-1,0,-2,0,4,-2,0,4,-2,];
		// notes=notes++[-2,0,3,-2,0,3,-2,2,-2,0,3,-2,0,3,-2,0];
		//
		// notes=[0,3,7,5,0,3,7,5,0,3,7,5,0,3,7,5];
		// notes=[7,3,0,7,3,0,7,3,7,3,0,7,3,0,7,3];
		// notes=notes++[-1,2,5,-1,2,5,-1,2,-1,2,5,-1,2,5,-1,2];
		// notes=notes++[1,3,7,1,3,7,1,3,1,3,7,1,3,7,1,3];
		// notes=notes++[0,2,8,0,2,8,0,2,0,2,8,0,2,8,0,2];
		// notes=notes++[5];

		// define 65 notes
		notes=[-2,0,2,-2,0,2,-2,0,-2,0,2,-2,0,2,-2,0];
		notes=notes++[-2,0,3,-2,0,3,-2,0,-2,0,3,-2,0,3,-2,0];
		notes=notes++[-3,-1,2,-3,-1,2,-3,-1,-3,-1,2,-3,-1,2,-3,-1];
		notes=notes++[-3,-1,1,-3,-1,1,-3,-1,-3,-1,1,-3,-1,1,-3,-1];
		notes=notes++[3]; // 65th note is key
		scale=[0,2,4,5,7,9,11];
		octaves=[0,0,0,12,12,12,24,24];
		syncopation=[1,0.5,1,0.5,0.5,1,0.5,1];
		syncopation=[1];
		t.schedAbs(0, { arg i, sec;
			var note=scale[notes[i.mod(notes.size)].mod(scale.size)]+octaves[i.mod(octaves.size)]+32;
			var accent=syncopation[i.mod(syncopation.size)];
			[i,note-32,notes[i.mod(notes.size)],scale[notes[i.mod(notes.size)]]].postln;
			Synth("jp",[\freq,note.midicps,\mix,(90+10.rand)/100,\detune,(15+30.rand)/100,\amp,accent,\lpf,18-(accent*12)]);
			1
		});


		/*		notes2=[0,2,-2,0,2,-2,0,-2,0,2,-2,0,2,-2,0,-2];
		notes2=notes2++[0,3,-2,0,3,-2,0,-2,0,3,-2,0,3,-2,0,-2];
		notes2=notes2++[-1,2,-3,-1,2,-3,-1,-3,-1,2,-3,-1,2,-3,-1,-3];
		notes2=notes2++[-1,1,-3,-1,1,-3,-1,-3,-1,1,-3,-1,1,-3,-1,-3];
		notes2=notes2++[3]; // 65th note is key
		scale=[0,2,4,5,7,9,11];
		octaves2=[0,0,0,12,24,12,24,12];
		syncopation2=[1,0.5,1,0.5,0.5,1,0.5,1];
		t2.schedAbs(0, { arg i, sec;
		var note=scale[notes2[i.mod(notes2.size)].mod(scale.size)]+octaves2[i.mod(octaves2.size)]+32;
		var accent=syncopation2[i.mod(syncopation2.size)];
		[i,note-32,notes2[i.mod(notes2.size)],scale[notes2[i.mod(notes2.size)]]].postln;
		Synth("jp",[\freq,note.midicps,\mix,(90+10.rand)/100,\detune,(25+30.rand)/100,\amp,accent,\lpf,18-(accent*12)]);
		1
		});*/

	}.play;
}
)
)

t = TempoClock(8*120/120);
{ t.tempo=MouseX.kr(100,200); }.play;
