package qrcode.encoder;

import qrcode.*;
using tink.CoreApi;

class NodeEncoder implements Encoder {
	public function new() {}
	
	public function encode(text:String):Promise<Data> {
		return QrImage.matrix(text);
	}
}

@:jsRequire('qr-image')
extern class QrImage {
	static function matrix(text:String):Array<Array<Int>>;
}