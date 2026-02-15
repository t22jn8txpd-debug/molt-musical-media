import 'dart:js_interop';

@JS('eval')
external JSAny _eval(String code);

/// Web Audio API mixer engine for channel volume, pan, and effects processing.
class WebMixerEngine {
  bool _initialized = false;

  void _ensureInit() {
    if (_initialized) return;
    _eval(r'''
      window.__moltMixer = (function() {
        var ctx = new (window.AudioContext || window.webkitAudioContext)();
        var channels = {};
        var masterGain = ctx.createGain();
        masterGain.connect(ctx.destination);

        // Effects chain nodes
        var reverbNode = null;
        var delayNode = ctx.createDelay(2.0);
        delayNode.delayTime.value = 0.3;
        var delayFeedback = ctx.createGain();
        delayFeedback.gain.value = 0.3;
        delayNode.connect(delayFeedback);
        delayFeedback.connect(delayNode);
        var delayWet = ctx.createGain();
        delayWet.gain.value = 0;
        delayNode.connect(delayWet);
        delayWet.connect(masterGain);

        // EQ nodes (low, mid, high)
        var eqLow = ctx.createBiquadFilter();
        eqLow.type = 'lowshelf';
        eqLow.frequency.value = 320;
        eqLow.gain.value = 0;

        var eqMid = ctx.createBiquadFilter();
        eqMid.type = 'peaking';
        eqMid.frequency.value = 1000;
        eqMid.Q.value = 0.5;
        eqMid.gain.value = 0;

        var eqHigh = ctx.createBiquadFilter();
        eqHigh.type = 'highshelf';
        eqHigh.frequency.value = 3200;
        eqHigh.gain.value = 0;

        eqLow.connect(eqMid);
        eqMid.connect(eqHigh);
        eqHigh.connect(masterGain);

        // Reverb (convolver with generated impulse)
        function createReverbImpulse(duration, decay) {
          var rate = ctx.sampleRate;
          var length = rate * duration;
          var impulse = ctx.createBuffer(2, length, rate);
          for (var ch = 0; ch < 2; ch++) {
            var data = impulse.getChannelData(ch);
            for (var i = 0; i < length; i++) {
              data[i] = (Math.random() * 2 - 1) * Math.pow(1 - i / length, decay);
            }
          }
          return impulse;
        }

        var convolver = ctx.createConvolver();
        convolver.buffer = createReverbImpulse(2, 2.5);
        var reverbWet = ctx.createGain();
        reverbWet.gain.value = 0;
        convolver.connect(reverbWet);
        reverbWet.connect(masterGain);

        function getOrCreateChannel(name) {
          if (channels[name]) return channels[name];
          var gain = ctx.createGain();
          var panner = ctx.createStereoPanner();
          gain.connect(panner);
          panner.connect(eqLow);
          panner.connect(delayNode);
          panner.connect(convolver);
          channels[name] = { gain: gain, panner: panner, muted: false, savedVol: 1.0 };
          return channels[name];
        }

        return {
          ctx: ctx,
          setVolume: function(name, vol) {
            var ch = getOrCreateChannel(name);
            ch.gain.gain.setTargetAtTime(vol, ctx.currentTime, 0.01);
            ch.savedVol = vol;
          },
          setPan: function(name, pan) {
            var ch = getOrCreateChannel(name);
            ch.panner.pan.setTargetAtTime(pan, ctx.currentTime, 0.01);
          },
          setMute: function(name, muted) {
            var ch = getOrCreateChannel(name);
            ch.muted = muted;
            ch.gain.gain.setTargetAtTime(muted ? 0 : ch.savedVol, ctx.currentTime, 0.01);
          },
          setMasterVolume: function(vol) {
            masterGain.gain.setTargetAtTime(vol, ctx.currentTime, 0.01);
          },
          setReverbWet: function(val) {
            reverbWet.gain.setTargetAtTime(val, ctx.currentTime, 0.01);
          },
          setDelayWet: function(val) {
            delayWet.gain.setTargetAtTime(val, ctx.currentTime, 0.01);
          },
          setDelayTime: function(val) {
            delayNode.delayTime.setTargetAtTime(val, ctx.currentTime, 0.01);
          },
          setEqLow: function(val) { eqLow.gain.value = val; },
          setEqMid: function(val) { eqMid.gain.value = val; },
          setEqHigh: function(val) { eqHigh.gain.value = val; },
          close: function() { ctx.close(); }
        };
      })();
    ''');
    _initialized = true;
  }

  void setVolume(String channelName, double volume) {
    _ensureInit();
    _eval('window.__moltMixer.setVolume("$channelName", $volume)');
  }

  void setPan(String channelName, double pan) {
    _ensureInit();
    _eval('window.__moltMixer.setPan("$channelName", $pan)');
  }

  void setMute(String channelName, bool muted) {
    _ensureInit();
    _eval('window.__moltMixer.setMute("$channelName", ${muted ? "true" : "false"})');
  }

  void setMasterVolume(double volume) {
    _ensureInit();
    _eval('window.__moltMixer.setMasterVolume($volume)');
  }

  void setReverbWet(double value) {
    _ensureInit();
    _eval('window.__moltMixer.setReverbWet($value)');
  }

  void setDelayWet(double value) {
    _ensureInit();
    _eval('window.__moltMixer.setDelayWet($value)');
  }

  void setDelayTime(double value) {
    _ensureInit();
    _eval('window.__moltMixer.setDelayTime($value)');
  }

  void setEqLow(double value) {
    _ensureInit();
    _eval('window.__moltMixer.setEqLow($value)');
  }

  void setEqMid(double value) {
    _ensureInit();
    _eval('window.__moltMixer.setEqMid($value)');
  }

  void setEqHigh(double value) {
    _ensureInit();
    _eval('window.__moltMixer.setEqHigh($value)');
  }

  void dispose() {
    if (_initialized) {
      _eval('if(window.__moltMixer){window.__moltMixer.close();window.__moltMixer=null;}');
      _initialized = false;
    }
  }
}
