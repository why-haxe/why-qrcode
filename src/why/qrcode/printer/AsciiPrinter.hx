package why.qrcode.printer;

import why.qrcode.Printer;
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
		for(y in 0...data.size) {
			for(x in 0...data.size)
				buf.add(data.get(x, y) ? filled : empty);
			buf.add('\n');
		}
		buf.add('\n');
		buf.add('\n');
		buf.add('\n');
		
		return buf.toString();
	}
}