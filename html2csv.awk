BEGIN {FS="\"|=\""}
/<param/{
	if($2 == "Name")
		Name=$4
	if($2 == "Local")
		print "\"" Name "\",\"dic/"  $4 "\""
}
