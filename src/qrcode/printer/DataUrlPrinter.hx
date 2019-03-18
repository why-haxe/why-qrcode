package qrcode.printer;

import js.Browser.document;
import qrcode.Printer;
using tink.CoreApi;

class DataUrlPrinter implements Printer<String> {
	
	var black:String;
	var white:String;
	var blockSize:Int;
	
	public function new(?options:Options) {
		if(options == null) options = {};
		this.black = options.black == null ? '#000000' : options.black;
		this.white = options.white == null ? '#ffffff' : options.white;
		this.blockSize = options.blockSize == null ? 4 : options.blockSize;
	}
	
	public function print(data:Data):Promise<String> {
		var canvas = document.createCanvasElement();
		var ctx = canvas.getContext2d();
		canvas.width = canvas.height = (data.size + 4) * blockSize;
		ctx.fillStyle = white;
		ctx.fillRect(0, 0, canvas.width, canvas.height);
		ctx.fillStyle = black;
		for(y in 0...data.size) for(x in 0...data.size)
			if (data.get(x, y)) ctx.fillRect((x + 2) * blockSize, (y + 2) * blockSize, blockSize, blockSize);
			
		return canvas.toDataURL();
	}
}


private typedef Options = {
	?black:String, // web color
	?white:String, // web color
	?blockSize:Int, // pixel size of each block
}