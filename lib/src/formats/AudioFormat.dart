import "dart:async";
import "dart:typed_data";
import "dart:web_audio";

import "Formats.dart";
import "../sound/audio.dart";

class AudioFormat extends BinaryFileFormat<AudioBuffer> {
    @override
    String mimeType() => "application/x-tar";

    @override
    Future<AudioBuffer> read(ByteBuffer input) => Audio.INSTANCE.ctx.decodeAudioData(input);

    @override
    Future<ByteBuffer> write(AudioBuffer data) { throw "Not Implemented"; }

    @override
    String header() => "";
}