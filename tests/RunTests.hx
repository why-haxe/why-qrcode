package ;

import haxe.io.*;
import qrcode.encoder.*;
import qrcode.printer.ImagePrinter;
import sys.io.File;
using tink.CoreApi;

class RunTests {

	static function main() {
		var encoder = new NodeEncoder();
		var filename = 'colorful';
		encoder.encode('http://links.letzbig.com/SEyV/3qmKWKZzGF')
			.next(function(data) {
				var bytes = File.getBytes('bin/$filename.png');
				var bitmap = PngCodec.decode(bytes);
				return new ImagePrinter(bitmap).print(data);
			})
			.handle(function(o) {
				var bitmap = o.sure();
				var bytes = BmpCodec.encode(bitmap);
				File.saveBytes('bin/$filename.bmp', bytes);
				travix.Logger.exit(0);
			});
	}

}



class PngCodec {
	public static function decode(bytes:Bytes):Bitmap {
		var reader = new format.png.Reader(new BytesInput(bytes));
		var data = reader.read();
		var header = format.png.Tools.getHeader(data);
		var pixels = format.png.Tools.extract32(data);
		return new Bitmap(header.width, header.height, pixels, BGRA);
	}
}

class BmpCodec {
	public static function encode(bitmap:Bitmap):Bytes {
		var output = new BytesOutput();
		var writer = new format.bmp.Writer(output);
		var data = format.bmp.Tools.buildFromBGRA(bitmap.width, bitmap.height, bitmap.pixels);
		writer.write(data);
		return output.getBytes();
	}
}