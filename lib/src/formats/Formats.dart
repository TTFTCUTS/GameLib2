import "AudioFormat.dart";
import "BasicFormats.dart";
import "BundleManifestFormat.dart";
import "FileFormat.dart";
import "FontFormat.dart";
import "ImageFormats.dart";
import "ZipFormat.dart";

export "FileFormat.dart";
export "AudioFormat.dart";
export "BasicFormats.dart";
export "BundleManifestFormat.dart";
export "FileFormat.dart";
export "FontFormat.dart";
export "ImageFormats.dart";
export "ZipFormat.dart";

abstract class Formats {
    static TextFileFormat text;
    static BundleManifestFormat manifest;
    static ZipFormat zip;

    static PngFileFormat png;

    static FontFormat font;

    static AudioFormat audio;

    static void init() {

        text = new TextFileFormat();
        addMapping(text, "txt");
        addMapping(text, "vert", "x-shader/x-vertex");
        addMapping(text, "frag", "x-shader/x-fragment");

        manifest = new BundleManifestFormat();

        zip = new ZipFormat();
        addMapping(zip, "zip");
        addMapping(zip, "bundle");

        png = new PngFileFormat();
        addMapping(png, "png");
        addMapping(png, "jpg", "image/jpeg");

        font = new FontFormat();
        addMapping(font, "ttf");
        addMapping(font, "otf");
        addMapping(font, "woff");

        audio = new AudioFormat();
        addMapping(audio, "mp3");
        addMapping(audio, "ogg");
    }

    static void addMapping<T,U>(FileFormat<T,U> format, String extension, [String mimeType = null]) {
        extensionMapping[extension] = new ExtensionMappingEntry<T,U>(format, mimeType);
        format.extensions.add(extension);
    }

    static Map<String, ExtensionMappingEntry<dynamic,dynamic>> extensionMapping = <String, ExtensionMappingEntry<dynamic,dynamic>>{};

    static ExtensionMappingEntry<T,U> getFormatEntryForExtension<T,U>(String extension) {
        if (extensionMapping.containsKey(extension)) {
            ExtensionMappingEntry<T,U> mapping = extensionMapping[extension];
            FileFormat<T,U> format = mapping.format;
            if (format is FileFormat<T,U>) {
                return mapping;
            }
            throw "File format for extension .$extension does not match expected types.";
        }
        throw "No file format found for extension .$extension";
    }

    static FileFormat<T,U> getFormatForExtension<T,U>(String extension) => getFormatEntryForExtension(extension).format;
    static String getMimeTypeForExtension(String extension) => getFormatEntryForExtension(extension).mimeType;
}

class ExtensionMappingEntry<T,U> {
    FileFormat<T,U> format;
    String mimeType;

    ExtensionMappingEntry(FileFormat<T,U> this.format, String this.mimeType);
}