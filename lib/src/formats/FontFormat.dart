import "dart:async";
import "dart:typed_data";

import "../font/opentype.dart" as OT;
import "Formats.dart";

class FontFormat extends BinaryFileFormat<OT.Font> {

    @override
    String mimeType() => "font/opentype";

    @override
    Future<OT.Font> read(ByteBuffer input) async {
        await OT.load();
        return OT.parse(input);
    }

    @override
    Future<ByteBuffer> write(OT.Font data) async => data.toArrayBuffer();

    @override
    String header() => "";
}