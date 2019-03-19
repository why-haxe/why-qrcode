# Why QR Code

Features: 

- Overlay QR Code on an image (see demo below)
- Generate data URL for browser use (js only)
- Generate OpenFL sprite

## Usage

```haxe
import why.qrcode.*;

var encoder:Encoder = /* pick one implemenation from the qrcode.encoder package */;
var printer:Printer = /* pick one implemenation from the qrcode.printer package */;

encoder.encode('https://haxe.org/') // encode a string value
	.next(printer.print) // a printer converts the raw QR code data into specific formats (e.g. DataURL, OpenFL Sprite, etc)
	.next(output -> trace(output)); // make use of the converted output
```

## Demo: QR Code over Image

#### Original Image

![Original](tests/haxe.png)

#### With QR Code

![Code](tests/haxe-code-full.png)