#! /usr/bin/awk -f

BEGIN {
	FS=" [ *]+";
	OFS="";
}

{
	split($4$5, a, "[ :]+");
	#print $1, $2, $3, a[2], a[4], a[6], a[8], a[10], a[12], a[14]

	print "\texpect(nes.reg.p.val).toEqual(0x", $1, ");"
	print "\texpect(nes.reg.a.val).toEqual(0x", a[2], ");"
	print "\texpect(nes.reg.x.val).toEqual(0x", a[4], ");"
	print "\texpect(nes.reg.y.val).toEqual(0x", a[6], ");"
	print "\texpect(nes.statusRegister()).toEqual(0x", a[8], ");"
	print "\texpect(nes.reg.s.val).toEqual(0x", a[10], ");"

	print "});\n\nit(\"", FNR, ": ", $3, "\", function() {"
}
