package qrcode.printer;

import haxe.io.*;
import qrcode.Printer;
using tink.CoreApi;

private typedef Options = {
	?intensityThreshold:Float,
	?black:{r:Int, g:Int, b:Int, a:Int},
	?white:{r:Int, g:Int, b:Int, a:Int},
	?fillRatio:Float,
	?canvas:{x:Int, y:Int, size:Int},
}

class ImagePrinter implements Printer<Bitmap> {
	
	var bitmap:Bitmap;
	var intensityThreshold:Float;
	var black:Pixel;
	var white:Pixel;
	var fillRatio:Float;
	var canvas:{x:Int, y:Int, size:Int};
	
	public function new(bitmap:Bitmap, ?options:Options) {
		this.bitmap = bitmap.clone();
		
		if(options == null) options = {};
		intensityThreshold = options.intensityThreshold != null ? options.intensityThreshold : 0.25;
		black = Pixel.make(options.black != null ? options.black : {r:0, g:0, b:0, a:160}, bitmap.format);
		white = Pixel.make(options.white != null ? options.white : {r:255, g:255, b:255, a:160}, bitmap.format);
		fillRatio = options.fillRatio != null ? options.fillRatio : 0.5;
		canvas = options.canvas != null ? options.canvas : getDefaultCanvas(bitmap.width, bitmap.height);
	}
	
	public function print(data:Data):Promise<Bitmap> {
		var blockSize = Std.int(canvas.size / (data.size + 2)); // in pixel
		var blockOffset = ((canvas.size - (data.size + 2) * blockSize) >> 1) + blockSize; // in pixel
		var blockOffsetX = blockOffset + canvas.x;
		var blockOffsetY = blockOffset + canvas.y;
		
		var fillSize = Math.round(blockSize * fillRatio);
		var fillOffset = (blockSize - fillSize) >> 1;
		
		function blockAverageColor(x, y) {
			return bitmap.average(x * blockSize + blockOffsetX, y * blockSize + blockOffsetY, blockSize, blockSize);
		}
		
		function fillBlock(x, y, offset, size, fill) {
			var sx = x * blockSize + blockOffsetX + offset;
			var ex = sx + size;
			var sy = y * blockSize + blockOffsetY + offset;
			var ey = sy + size;
			for(i in sx...ex) for(j in sy...ey) {
				var original = bitmap.getPixel(i, j);
				var blended = original.stamp(fill);
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
					if(intensity > intensityThreshold)
						fillBlock(x, y, offset, size, black);
				} else {
					if(intensity < 1 - intensityThreshold)
						fillBlock(x, y, offset, size, white);
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
		
		return bitmap;
	}
	
	function getDefaultCanvas(w, h) {
		if(w > h) return {x: (w - h) >> 1, y: 0, size: h};
		if(w < h) return {x: 0, y: (h - w) >> 1, size: w};
		return {x: 0, y: 0, size: w};
	}
}

class Bitmap {
	public var width(default, null):Int;
	public var height(default, null):Int;

	public var pixels(default, null):Bytes;
	public var format(default, null):PixelFormat;
	
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
		
		return new Pixel(
			Bytes.fastGet(data, offset + 0) << 24 |
			Bytes.fastGet(data, offset + 1) << 16 |
			Bytes.fastGet(data, offset + 2) << 8 |
			Bytes.fastGet(data, offset + 3),
			format
		);
	}
	
	public function average(x, y, w, h):Pixel {
		var v0 = 0, v1 = 0, v2 = 0, v3 = 0;
		var data = pixels.getData();
		for(i in x...x+w) for(j in y...y+h) {
			var offset = (j * width + i) * 4;
			v0 += Bytes.fastGet(data, offset + 0);
			v1 += Bytes.fastGet(data, offset + 1);
			v2 += Bytes.fastGet(data, offset + 2);
			v3 += Bytes.fastGet(data, offset + 3);
		}
		var n = w * h;
		
		return new Pixel(
			Math.round(v0/n) << 24 |
			Math.round(v1/n) << 16 |
			Math.round(v2/n) << 8 |
			Math.round(v3/n),
			format
		);
	}
	
	public function clone() {
		var bytes = Bytes.alloc(pixels.length);
		bytes.blit(0, pixels, 0, pixels.length);
		return new Bitmap(width, height, bytes, format);
	}
}

@:structInit
class Pixel {
	public var r(get, never):Int;
	public var g(get, never):Int;
	public var b(get, never):Int;
	public var a(get, never):Int;
	
	var value:Int;
	var format:PixelFormat;
	
	public static function make(v:{r:Int, g:Int, b:Int, a:Int}, format)
		return switch format {
			case BGRA: new Pixel(v.b<<24 | v.g<<16 | v.r<<8 | v.a, format);
		}
	
	public function new(value, format) {
		this.value = value;
		this.format = format;
	}
	
	public function intensity() {
		return switch format {
			case BGRA: .3 * r / 255 + .59 * g / 255 + .11 * b / 255;
		}
	}
	
	// stamp another pixel over this pixel
	public function stamp(other:Pixel):Pixel {
		var src_a = other.a / 255;
		var dst_a = a / 255;
		var one_minus_src_a = 1 - src_a;
		var out_a = src_a + dst_a * one_minus_src_a;
		
		var out = {
			a: Math.round(out_a * 255),
			r: Math.round((other.r * src_a + r * dst_a * one_minus_src_a) / out_a),
			g: Math.round((other.g * src_a + g * dst_a * one_minus_src_a) / out_a),
			b: Math.round((other.b * src_a + b * dst_a * one_minus_src_a) / out_a),
		}
		
		return Pixel.make(out, format);
	}
	
	inline function get_r()
		return switch format {
			case BGRA: value >> 8 & 0xff;
		}
	
	inline function get_g()
		return switch format {
			case BGRA: value >> 16 & 0xff;
		}
	
	inline function get_b()
		return switch format {
			case BGRA: value >> 24 & 0xff;
		}
	
	inline function get_a()
		return switch format {
			case BGRA: value & 0xff;
		}
}

enum PixelFormat {
	BGRA;
}