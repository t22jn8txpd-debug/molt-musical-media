import 'dart:js_interop';

@JS('eval')
external JSAny _eval(String code);

/// Web Audio API engine using JS eval for reliable cross-version compatibility.
/// Synthesizes kick, snare, hi-hat, and clap sounds using oscillators.
class WebAudioEngine {
  bool _initialized = false;

  void _ensureInit() {
    if (_initialized) return;
    _eval(r'''
      window.__moltAudio = (function() {
        var ctx = new (window.AudioContext || window.webkitAudioContext)();

        function playKick(vol) {
          var t = ctx.currentTime;
          var osc = ctx.createOscillator();
          var gain = ctx.createGain();
          osc.connect(gain);
          gain.connect(ctx.destination);
          osc.frequency.setValueAtTime(150, t);
          osc.frequency.exponentialRampToValueAtTime(0.01, t + 0.5);
          gain.gain.setValueAtTime(vol, t);
          gain.gain.exponentialRampToValueAtTime(0.001, t + 0.5);
          osc.start(t);
          osc.stop(t + 0.5);
        }

        function playSnare(vol) {
          var t = ctx.currentTime;
          var osc = ctx.createOscillator();
          osc.type = 'triangle';
          var gain = ctx.createGain();
          osc.connect(gain);
          gain.connect(ctx.destination);
          osc.frequency.setValueAtTime(300, t);
          osc.frequency.exponentialRampToValueAtTime(100, t + 0.2);
          gain.gain.setValueAtTime(vol, t);
          gain.gain.exponentialRampToValueAtTime(0.001, t + 0.2);
          osc.start(t);
          osc.stop(t + 0.2);

          var osc2 = ctx.createOscillator();
          osc2.type = 'sawtooth';
          var gain2 = ctx.createGain();
          osc2.connect(gain2);
          gain2.connect(ctx.destination);
          osc2.frequency.setValueAtTime(3500, t);
          osc2.frequency.exponentialRampToValueAtTime(1000, t + 0.15);
          gain2.gain.setValueAtTime(vol * 0.4, t);
          gain2.gain.exponentialRampToValueAtTime(0.001, t + 0.15);
          osc2.start(t);
          osc2.stop(t + 0.15);
        }

        function playHiHat(vol) {
          var t = ctx.currentTime;
          var osc = ctx.createOscillator();
          osc.type = 'square';
          var gain = ctx.createGain();
          osc.connect(gain);
          gain.connect(ctx.destination);
          osc.frequency.setValueAtTime(8000, t);
          osc.frequency.exponentialRampToValueAtTime(4000, t + 0.05);
          gain.gain.setValueAtTime(vol, t);
          gain.gain.exponentialRampToValueAtTime(0.001, t + 0.08);
          osc.start(t);
          osc.stop(t + 0.08);
        }

        function playClap(vol) {
          var t = ctx.currentTime;
          for (var i = 0; i < 3; i++) {
            var offset = t + i * 0.01;
            var osc = ctx.createOscillator();
            osc.type = 'sawtooth';
            var gain = ctx.createGain();
            osc.connect(gain);
            gain.connect(ctx.destination);
            osc.frequency.setValueAtTime(2500 + i * 500, offset);
            osc.frequency.exponentialRampToValueAtTime(800, offset + 0.1);
            gain.gain.setValueAtTime(vol * 0.5, offset);
            gain.gain.exponentialRampToValueAtTime(0.001, offset + 0.12);
            osc.start(offset);
            osc.stop(offset + 0.12);
          }
        }

        return {
          ctx: ctx,
          playKick: playKick,
          playSnare: playSnare,
          playHiHat: playHiHat,
          playClap: playClap,
          play: function(idx, vol) {
            if (ctx.state === 'suspended') ctx.resume();
            switch(idx) {
              case 0: playKick(vol); break;
              case 1: playSnare(vol); break;
              case 2: playHiHat(vol); break;
              case 3: playClap(vol); break;
            }
          },
          close: function() { ctx.close(); }
        };
      })();
    ''');
    _initialized = true;
  }

  /// Play a sound for the given instrument index (0=kick, 1=snare, 2=hihat, 3=clap).
  void playInstrument(int index, {double volume = 0.7}) {
    _ensureInit();
    _eval('window.__moltAudio.play($index, $volume)');
  }

  void dispose() {
    if (_initialized) {
      _eval('if(window.__moltAudio){window.__moltAudio.close();window.__moltAudio=null;}');
      _initialized = false;
    }
  }
}
