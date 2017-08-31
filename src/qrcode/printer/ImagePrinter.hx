package qrcode.printer;

import haxe.io.*;
import qrcode.Printer;
using tink.CoreApi;

class ImagePrinter implements Printer<Noise> {
	var bitmap:Bitmap
	public function new(bitmap) {
		this.bitmap = bitmap;
	}
	
	public function print(data:Data):Promise<Noise> {
		var filename = 'letzbig';
		var bitmap = readPng(sys.io.File.getBytes('bin/$filename.png'));
		if(Math.abs(bitmap.width - bitmap.height) > 1) return new Error('Only accepts square images');
		
		var blockSize = Std.int(bitmap.width / (data.size + 2)); // in pixel
		var blockOffset = ((bitmap.width - (data.size + 2) * blockSize) >> 1) + blockSize; // in pixel
		
		var white = {r:255, g:255, b:255, a:160};
		var black = {r:0, g:0, b:0, a:160};
		
		var fillOffset = Math.round(blockSize * 0.25);
		var fillSize = blockSize - fillOffset * 2;
		
		function blockAverageColor(x, y) {
			return bitmap.average(x * blockSize + blockOffset, y * blockSize + blockOffset, blockSize, blockSize);
		}
		
		function fillBlock(x, y, offset, size, fill) {
			var sx = x * blockSize + blockOffset + offset;
			var ex = sx + size;
			var sy = y * blockSize + blockOffset + offset;
			var ey = sy + size;
			for(i in sx...ex) for(j in sy...ey) {
				var original = bitmap.getPixel(i, j);
				var blended = original.blend(fill);
				bitmap.setPixel(i, j, blended);
			}
		}
		
		for(x in 0...data.size) {
			for(y in 0...data.size) {
				var avg = blockAverageColor(x, y);
				var intensity = avg.intensity();
				var isEye = data.isEye(x, y);
				var offset = isEye ? 0 : fillOffset;
				var size = isEye ? blockSize : fillSize;
				if(data.get(x, y)) {
					if(intensity > 0.25) {
						fillBlock(x, y, offset, size, black);
					}
				} else {
					if(intensity < 0.75) {
						fillBlock(x, y, offset, size, white);
					}
				}
			}
		}
		
		for(x in -1...8) {
			fillBlock(x, -1, 0, blockSize, white);
			fillBlock(x, data.size, 0, blockSize, white);
		}
		
		for(y in -1...8) {
			fillBlock(-1, y, 0, blockSize, white);
			fillBlock(data.size, y, 0, blockSize, white);
		}
		
		for(x in data.size-8...data.size+1) {
			fillBlock(x, -1, 0, blockSize, white);
		}
		
		for(y in data.size-8...data.size+1) {
			fillBlock(-1, y, 0, blockSize, white);
		}
		
		var bytes = writePng(bitmap);
		sys.io.File.saveBytes('bin/$filename.bmp', bytes);
		
		return Noise;
	}
	
	function readPng(bytes:Bytes) {
		var reader = new format.png.Reader(new BytesInput(bytes));
		var data = reader.read();
		var header = format.png.Tools.getHeader(data);
		var pixels = format.png.Tools.extract32(data);
		return new Bitmap(header.width, header.height, pixels, BGRA);
	}
	
	function writePng(bitmap:Bitmap) {
		var output = new BytesOutput();
		var writer = new format.bmp.Writer(output);
		var data = format.bmp.Tools.buildFromBGRA(bitmap.width, bitmap.height, bitmap.pixels);
		writer.write(data);
		return output.getBytes();
	}
}

class Bitmap {
	public var width(default, null):Int;
	public var height(default, null):Int;
	
	public var pixels(default, null):Bytes;
	var format(default, null):PixelFormat;
	
	public function new(width, height, pixels, format) {
		this.width = width;
		this.height = height;
		this.pixels = pixels;
		this.format = format;
	}
	
	public function setPixel(x, y, pixel:Pixel) {
		var offset = (y * width + x) * 4;
		switch format {
			case BGRA:
				pixels.set(offset + 0, pixel.b);
				pixels.set(offset + 1, pixel.g);
				pixels.set(offset + 2, pixel.r);
				pixels.set(offset + 3, pixel.a);
		}
	}
	
	public function getPixel(x, y):Pixel {
		var r, g, b, a;
		var offset = (y * width + x) * 4;
		var data = pixels.getData();
		switch format {
			case BGRA:
				b = Bytes.fastGet(data, offset + 0);
				g = Bytes.fastGet(data, offset + 1);
				r = Bytes.fastGet(data, offset + 2);
				a = Bytes.fastGet(data, offset + 3);
		}
		
		return {r:r, g:g, b:b, a:a};
	}
	
	public function average(x, y, w, h):Pixel {
		var r = 0, g = 0, b = 0, a = 0;
		var data = pixels.getData();
		for(i in x...x+w) for(j in y...y+h) {
			var offset = (j * width + i) * 4;
			switch format {
				case BGRA:
					b += Bytes.fastGet(data, offset + 0);
					g += Bytes.fastGet(data, offset + 1);
					r += Bytes.fastGet(data, offset + 2);
					a += Bytes.fastGet(data, offset + 3);
			}
		}
		var n = w * h;
		return {r:Math.round(r/n), g:Math.round(g/n), b:Math.round(b/n), a:Math.round(a/n)};
	}
	
	public function clone() {
		var bytes = Bytes.alloc(pixels.length);
		bytes.blit(0, pixels, 0, pixels.length);
		return new Bitmap(width, height, bytes, format);
	}
}

@:forward
abstract Pixel({r:Int, g:Int, b:Int, a:Int}) from {r:Int, g:Int, b:Int, a:Int} {
	public function intensity() 
		return .3 * this.r / 255 + .59 * this.g / 255 + .11 * this.b / 255;
	
	public function blend(other:Pixel):Pixel {
		
		var src_a = other.a / 255;
		var dst_a = this.a / 255;
		var one_minus_src_a = 1 - src_a;
		var out_a = src_a + dst_a * one_minus_src_a;
		
		return {
			a: Math.round(out_a * 255),
			r: Math.round((other.r * src_a + this.r * dst_a * one_minus_src_a) / out_a),
			g: Math.round((other.g * src_a + this.g * dst_a * one_minus_src_a) / out_a),
			b: Math.round((other.b * src_a + this.b * dst_a * one_minus_src_a) / out_a),
		}
	}
}

enum PixelFormat {
	BGRA;
}