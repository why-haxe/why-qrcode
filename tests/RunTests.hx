package ;

import qrcode.encoder.NodeEncoder;
import qrcode.printer.ImagePrinter;
import qrcode.helper.png.NodePngCodec;
import js.node.Buffer;
import sys.io.File;
using tink.CoreApi;

class RunTests {

	static function main() {
		var width = 392, height = 392, size = 200;
		
		Promise.inParallel([
			run({}, 'code-full'),
			// run({canvas:{x: 10, y: 10, size: size}}, 'code-top-left'),
			// run({canvas:{x: (width - 300) >> 1, y: 0, size: 300}}, 'code-middle'),
			// run({canvas:{x:width - size - 10, y: height - size - 10, size: size}}, 'code-bottom-right'),
		]).handle(function(o) trace(Std.string(o)));
	}
	
	
	static function run(options, suffix) {
		var encoder = new NodeEncoder();
		var filename = 'haxe';
		return encoder.encode('https://haxe.org/')
			.next(function(data) {
				
				var ascii = new qrcode.printer.AsciiPrinter();
				ascii.print(data).handle(function(o) Sys.println(o.sure()));
				
				return NodePngCodec.bitmapFromFile('tests/$filename.png')
					.next(function(bitmap) return new ImagePrinter(bitmap, options).print(data));
			})
			.next(function(bitmap) {
				return NodePngCodec.bitmapToFile(bitmap, 'tests/$filename-$suffix.png');
			});
	}

}
