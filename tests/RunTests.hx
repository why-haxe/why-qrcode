package ;

using tink.CoreApi;

class RunTests {

	static function main() {
		var encoder = new qrcode.encoder.NodeEncoder();
		encoder.encode('http://links.letzbig.com/SEyV/3qmKWKZzGF')
			.next(function(data) return new qrcode.printer.ImagePrinter().print(data))
			.handle(function(o) {
				trace('\n',o.sure());
				travix.Logger.exit(0);
			});
	}

}