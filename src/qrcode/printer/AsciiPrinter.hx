package qrcode.printer;

import qrcode.Printer;
using tink.CoreApi;

class AsciiPrinter implements Printer<String> {
	public function new() {}
	
	public function print(data:Data):Promise<String> {
		var empty = '  ';
		var filled = '\u2588\u2588';
		
		var buf = new StringBuf();
		buf.add('\n');
		buf.add('\n');
		buf.add('\n');
		for(x in 0...data.length) {
			for(y in 0...data[0].length)
				buf.add(data[x][y] == 1 ? filled : empty);
			buf.add('\n');
		}
		buf.add('\n');
		buf.add('\n');
		buf.add('\n');
		
		return buf.toString();
	}
}