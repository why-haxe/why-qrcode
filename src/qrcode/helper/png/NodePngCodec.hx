package qrcode.helper.png;

import js.node.Buffer;
import js.node.Fs;
import js.node.stream.Writable;
import js.node.stream.Readable;
import js.node.events.EventEmitter;
import qrcode.printer.ImagePrinter;

using tink.CoreApi;

class NodePngCodec {
	public static function bitmapFromFile(path:String):Promise<Bitmap> {
		return Future.async(function(cb) {
			var width = 0, height = 0;
			Fs.createReadStream(path)
				.pipe(new PNG())
				.on('parsed', function(data) {
					var png:PNG = js.Lib.nativeThis;
					cb(Success(new Bitmap(png.width, png.height, png.data.hxToBytes(), RGBA)));
				})
				.on('error', function(e:js.Error) {
					cb(Failure(tink.core.Error.withData(e.message, e)));
				});
		});
	}
	
	public static function bitmapToBuffer(bitmap:Bitmap):Promise<Buffer> {
		return Future.async(function(cb) {
			var png = bitmapToPngObject(bitmap);
			
			var bufs = [];
			png.pack()
				.on('data', function(data) {
					bufs.push(data);
				})
				.on('end', function(data) {
					cb(Success(Buffer.concat(bufs)));
				})
				.on('error', function(e:js.Error) {
					cb(Failure(tink.core.Error.withData(e.message, e)));
				});
		});
	}
	
	public static function bitmapToFile(bitmap:Bitmap, path:String):Promise<Noise> {
		return Future.async(function(cb) {
			var png = bitmapToPngObject(bitmap);
			png.pack().pipe(Fs.createWriteStream(path))
				.on('close', cb.bind(Success(Noise)))
				.on('error', function(e:js.Error) {
					cb(Failure(tink.core.Error.withData(e.message, e)));
				});
		});
	}
	static function bitmapToPngObject(bitmap:Bitmap):PNG {
		var png = new PNG({
			width: bitmap.width,
			height: bitmap.height,
		});
		png.data = Buffer.hxFromBytes(bitmap.pixels);
		return png;
	}
		
}


@:jsRequire('pngjs', 'PNG')
extern class PNG extends Writable<PNG> {
	function new(?options:{});
	function pack():IReadable;
	
	var width:Int;
	var height:Int;
	var data:Buffer;
}