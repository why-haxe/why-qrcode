package qrcode;

abstract Data(Array<Array<Int>>) from Array<Array<Int>> {
	public inline function new(data)
		this = data;
		
	public var size(get, never):Int;
	inline function get_size()
		return this.length;
	
	public inline function get(x, y)
		return this[x][y] == 1;
	
	public inline function isEye(x, y) {
		return 
			(x <= 7 && y <= 7) ||
			(x >= this.length - 8 && y <= 7) ||
			(x <= 7 && y >= this.length - 8);
	}
}