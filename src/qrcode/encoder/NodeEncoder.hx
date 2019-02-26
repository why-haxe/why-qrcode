package qrcode.encoder;

import qrcode.*;
using tink.CoreApi;

class NodeEncoder implements Encoder {
	var errorCorrectionLevel:ErrorCorrectionLevel;
	public function new(?errorCorrectionLevel) {
		this.errorCorrectionLevel = errorCorrectionLevel;
	}
	
	public function encode(text:String):Promise<Data> {
		return QrImage.matrix(text, errorCorrectionLevel);
	}
}

@:jsRequire('qr-image')
extern class QrImage {
	static function matrix(text:String, ?errorCorrectionLevel:ErrorCorrectionLevel):Array<Array<Int>>;
}

@:enum
private abstract ErrorCorrectionLevel(String) {
	var L = 'L';
	var M = 'M';
	var Q = 'Q';
	var H = 'H';
}