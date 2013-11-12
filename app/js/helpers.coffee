window.ab2str = (buf) ->
	String.fromCharCode.apply(null, new Uint8Array(buf))

window.str2ab = (str) ->
	buf = new ArrayBuffer(str.length*2)
	bufView = new Uint8Array(buf)

	(bufView[i] = str.charCodeAt(i) for i in [0...str.length])

	return bufView


window.byteToAddr = (l, h) ->
	return (h << 8) + l

window.toSigned = (val) ->
	return if val >= 0x80 then val - 0x100 else val