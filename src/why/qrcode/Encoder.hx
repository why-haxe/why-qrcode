package why.qrcode;

using tink.CoreApi;

interface Encoder {
	function encode(text:String):Promise<Data>;
}