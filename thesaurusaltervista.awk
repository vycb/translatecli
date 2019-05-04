#!/usr/bin/awk -f

BEGIN {out="";OFS = " ";
	while ( getXML("",0) ) { #ARGV[1]
		if(XITEM == "category" ||XITEM == "synonyms" || XITEM == "antonym")
			tg = XITEM
		if(XTYPE == "DAT"){
			gsub(" +|\t+|\n+|\t\r+","",XITEM)
			if(tg == "category" && !TAG[XITEM]){
				out="" XITEM
				TAG[XITEM] = 1
			}
			else if(tg == "synonyms"|| tg == "antonym"){
				if(XITEM!="")
					out = out "\n" "   -" XITEM
			}
		}
	}
	if(XERROR){getline S0
		print XERROR;
		exit 1;
	}
 }
 END{
 	if(!out) exit 1;
 	print "thesaurus.altervista.org:\n","\033[1;38m" se":\n\033[00m", out
}
 
