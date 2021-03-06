import "dart:async";
import "dart:html";
import "dart:math";
import "dart:web_audio";

import "../loader/loader.dart";

class Audio {
    static Audio INSTANCE;

    Random rand = new Random();
    AudioContext ctx;

    Map<String, AudioChannel> channels = <String, AudioChannel>{};

    GainNode volumeNode;
    double volume = 1.0;

    String path;
    String extension = "ogg";

    Element subtitleElement;

    Audio(String this.path, [Element this.subtitleElement]) {
        this.ctx = new AudioContext();
        this.volumeNode = ctx.createGain()..connectNode(ctx.destination);

        AudioElement a = new AudioElement();
        if (a.canPlayType("audio/mpeg;codecs=mp3") != "") {
            this.extension = "mp3";
        };

        INSTANCE = this;
    }

    void icreateChannel(String name, [double defaultVolume = 1.0]) {
        if (channels.containsKey(name)) {
            throw "Audio channel already exists!";
        }

        channels[name] = new AudioChannel(name, this, defaultVolume);
    }

    Future<AudioBufferSourceNode> iplay(String soundname, String channel, {String subtitle, double pitchVar = 0.0}) async {
        if (channels.containsKey(channel)) {
            return channels[channel].play(soundname, subtitle: subtitle, pitchVar: pitchVar);
        }
        return null;
    }

    Future<AudioBufferSourceNode> iplayRandom(List<String> soundnames, String channel, {List<String> subtitles, double pitchVar = 0.0}) async {
        if (soundnames.length == 0) { return null; }
        if (subtitles == null) { subtitles = <String>[]; }
        if (soundnames.length < 2) {
            return iplay(soundnames[0], channel, subtitle: subtitles.length > 0 ? subtitles[0] : null, pitchVar: pitchVar);
        } else {
            int n = rand.nextInt(soundnames.length);
            return iplay(soundnames[n], channel, subtitle: subtitles.length > n ? subtitles[n] : null, pitchVar: pitchVar);
        }
    }

    String processSoundName(String name) {
        return "$path/$name.$extension";
    }

    static Future<AudioBufferSourceNode> play(String soundname, String channel, {String subtitle, double pitchVar = 0.0}) async {
        return INSTANCE.iplay(soundname, channel, subtitle: subtitle, pitchVar: pitchVar);
    }

    static Future<AudioBufferSourceNode> playRandom(List<String> soundnames, String channel, {List<String> subtitles, double pitchVar = 0.0}) async {
        return INSTANCE.iplayRandom(soundnames, channel, subtitles: subtitles, pitchVar: pitchVar);
    }

    void displaySubtitle(String subtitle, num duration) {
        if (this.subtitleElement == null) { return; }
        int ms = (duration * 1000).ceil();

        DivElement sub = new DivElement()
            ..className="subtitle"
            ..text = subtitle;
        this.subtitleElement.append(sub);

        new Timer(new Duration(milliseconds: ms), sub.remove);
    }

    static void createChannel(String name, [double defaultVolume = 1.0]) {
        INSTANCE.icreateChannel(name, defaultVolume);
    }
}

class AudioChannel {
    final Audio system;
    final String name;
    final GainNode volumeNode;

    double volume;

    AudioChannel(String this.name, Audio this.system, [double defaultVolume = 1.0]) : volumeNode = system.ctx.createGain() {
        this.volumeNode.connectNode(system.volumeNode);
        volume = defaultVolume;
        this.volumeNode.gain.value = volume;
    }

    Future<AudioBufferSourceNode> play(String soundname, {String subtitle, double pitchVar = 0.0}) async {
        if (soundname == null) { return null; }

        AudioBuffer sound = await Loader.getResource(system.processSoundName(soundname));

        AudioBufferSourceNode node = system.ctx.createBufferSource()
            ..buffer = sound
            ..connectNode(volumeNode);

        if (pitchVar > 0.0) {
            double variance = system.rand.nextDouble() * pitchVar;

            if (system.rand.nextBool()) {
                // pitch up
                node.playbackRate.value = 1.0 + variance;
            } else {
                // pitch down
                node.playbackRate.value = 1.0 / (1.0 + variance);
            }
        }

        node..start(0);


        if (subtitle != null) {
            system.displaySubtitle(subtitle, sound.duration);
        }
        return node;
    }
}