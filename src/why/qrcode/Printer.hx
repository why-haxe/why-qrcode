package why.qrcode;

using tink.CoreApi;

interface Printer<T> {
	function print(data:Data):Promise<T>;
}