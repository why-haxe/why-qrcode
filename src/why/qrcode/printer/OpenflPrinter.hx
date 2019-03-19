package why.qrcode.printer;

import why.qrcode.*;
import openfl.display.*;

using tink.CoreApi;

class OpenflPrinter implements Printer<Sprite> {
	var margin:Int;
	var blockSize:Int;
	var backgroundColor:Int;
	var foregroundColor:Int;
	
	public function new(?options:OpenflPrinterOptions) {
		margin = options == null || options.margin == null ? 4 : options.margin;
		blockSize = options == null || options.blockSize == null ? 4 : options.blockSize;
		backgroundColor = options == null || options.backgroundColor == null ? 0xffffff : options.backgroundColor;
		foregroundColor = options == null || options.foregroundColor == null ? 0x000000 : options.foregroundColor;
	}
		
		
	public function print(data:Data):Promise<Sprite> {
		var sprite = new Sprite();
		var size = data.size;
		
		var bg = new Bitmap(new BitmapData(blockSize, blockSize, false, backgroundColor));
		bg.scaleX = bg.scaleY = (size + margin * 2);
		
		var bitmapData = new BitmapData(size, size);
		bitmapData.lock();
		for(x in 0...size) for(y in 0...size) {
			bitmapData.setPixel(x, y, data.get(x, y) ? foregroundColor : backgroundColor);
		}
		bitmapData.unlock();
		
		var code = new Bitmap(bitmapData);
		code.x = code.y = margin * blockSize;
		code.scaleX = code.scaleY = blockSize;
		
		sprite.addChild(bg);
		sprite.addChild(code);
		
		return sprite;
	}
}

typedef OpenflPrinterOptions = {
	?margin:Int,
	?blockSize:Int,
	?backgroundColor:Int,
	?foregroundColor:Int,
}