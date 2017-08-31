package ;

import haxe.io.*;
import qrcode.encoder.*;
import qrcode.printer.ImagePrinter;
import js.node.Buffer;
import sys.io.File;
using tink.CoreApi;

class RunTests {

	static function main() {
		var width = 392, height = 392, size = 200;
		Promise.inParallel([
			run({}, 'code-full'),
			run({canvas:{x: 10, y: 10, size: size}}, 'code-top-left'),
			run({canvas:{x: (width - size) >> 1, y: (height - size) >> 1, size: size}}, 'code-middle'),
			run({canvas:{x:width - size - 10, y: height - size - 10, size: size}}, 'code-bottom-right'),
		]).handle(function(o) trace(Std.string(o)));
	}
	
	static function run(options, suffix) {
		var encoder = new NodeEncoder();
		var filename = 'haxe';
		var png = null;
		return encoder.encode('https://github.com/kevinresol/qrcode')
			.next(function(data) {
				var bytes = File.getBytes('tests/$filename.png');
				var buffer = Buffer.hxFromBytes(bytes);
				png = PNG.read(buffer);
				var bitmap = new Bitmap(png.width, png.height, png.data.hxToBytes(), RGBA);
				return new ImagePrinter(bitmap, options).print(data);
			})
			.next(function(bitmap) {
				png.data = Buffer.hxFromBytes(bitmap.pixels);
				var buffer = PNG.write(png);
				File.saveBytes('tests/$filename-$suffix.png', buffer.hxToBytes());
				return Noise;
			});
	}

}

@:jsRequire('pngjs', 'PNG.sync')
extern class PNG {
	static function read(buffer:Buffer):Png;
	static function write(png:Png):Buffer;
}

typedef Png = {
	width:Int,
	height:Int,
	depth:Int,
	interlace:Bool,
	palette:Bool,
	color:Bool,
	alpha:Bool,
	bpp:Int,
	colorType:Int,
	data:Buffer,
	gamma:Int,
}
