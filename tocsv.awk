@include "getXML.awk"

BEGIN {
	while ( getXML(ARGV[1],1) ) {
		 print XTYPE, XITEM;
		 for (attrName in XATTR) print "\t" attrName "=" XATTR[attrName]
		 se = XTYPE; 
			switch (se) {
			case "TAG":
				inEl = XITEM
				if (inEl == "param") {
					if (XATTR["name"] == "Name") {
						name = XATTR["value"]
					}
					else if(XATTR["name"] == "Local") {
						local = XATTR["value"]
						print "\"" name "\",\"" local "\""
					}
				}
				break

			} #switch

			if (XERROR) {
				 print XERROR
			}
	} #while
} # BEGIN
