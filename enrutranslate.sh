#! /bin/bash -
. /home/bin/bashruntime.sh

if [ $# -eq 0 -o  "$1" = 'h' -o  "$1" = '-h'  -o "$1" = '--help' ]
then
	#awk '/HELP$/{H=1;}; /^HELP$/{H=0}; !/HELP$|^HELP$/{if(H){print}}' "$0"
  sed -n '/HELP$/,/^HELP$/{/HELP$/d; p}' "$0"  #/HELP$/d
 	exit 0;
:<<HELP
Usage:
HELP
	exit 0
fi
home=${TRANSLATECLI_HOME:="$HOME/.vim/doc/englishtranslate"}

urlencode(){
	awk 'BEGIN {while (y++ < 125) z[sprintf("%c", y)] = y}
	{while (y = substr($0, ++j, 1))
		q = y ~ /[[:alnum:]_.!~*\47()-]/ ? q y : q sprintf("%%%02X", z[y])
		print q}'
}

getpage(){
	#tar -xjOf $lang'translate.tar.bz2' toc.csv | \#{{{#{{{
	#unzip -c $lang'translate.zip' toc.csv | \#}}}
	tar -xzOf $lang'translate.tar.gz' toc.csv | \
	awk -v se="${1}" 'BEGIN{FS="\",\"|^\"|\"$"; RS="\"\n";IGNORECASE = 1}
    {
			#tmp=match($2, se)
      #if( tmp )
      if($2 == se)
				{ print $3; exit 1;}
		}'
}
#}}}

getelinks(){
#{{{
( elinks -no-references -no-numbering -dump )<  \
    <(tar -xzOf $lang'translate.tar.gz' "$1")
} #}}}

pageout(){
#{{{
 	page=$(getpage "$2")
	if [[ ! $page ]]; then echo There is no page $2 ; exit 0; fi
	extension="${page##*.}"
	#debug :$1:$2:$#:$extension:
	echo -e "PAGEVAR\n$page\nPAGEVAR"
	if [ $extension = 'txt' ]; then 
		tar -xzOf $lang'translate.tar.gz' "$page"
	else
		getelinks "$page"
	fi
} #}}}

thesaurus(){
#{{{
	cmd='curl -s -c /tmp/lynxcookies'
	apikey='GawlDkBnfT0aQ7MTBWXq'
	word=`echo "$2" |urlencode`
	language='en_US'
	url='http://thesaurus.altervista.org/thesaurus/v1?word='$word'&language='$language'&key='$apikey'&output=xml'
	#echo $url
	echo `${cmd} -A 'Mozilla/5.0 (Android; Mobile; rv:62.0) Gecko/62.0 Firefox/62.0' -L -b "PHPSESSID=3c5a1ce42e0bddbb62bbdd0608e3cc97;__cfduid=df62b33881797a9df54020dfc579c21d11539243258" $url`|\
		#cat tezauras.xml|
awk -v se="$2" '@include "getXML.awk"
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
 '
} #}}}

[[ $0 =~ 'enru' ]] &&	lang='enru' || lang='ruen'
#echo $lang
cd $home #> /dev/null 2>&1

if [[ $# -eq 1 ]] && [ "$1" != b ] && [ "$1" != diff ]; then
#{{{#{{{	
:<<HELP
 pattern - to search dictionary. Example: enrutranslate.sh peace
HELP
#}}}
    #debug :$1:$2:$#:
    #unzip -c $lang'translate.zip' toc.csv | \#{{{
    #tar -xjOf $lang'translate.tar.bz2' toc.csv | \#}}}
    tar -xzOf $lang'translate.tar.gz' toc.csv | \
			awk -v se="$1" 'BEGIN{FS="\",\"|^\"|\"$"; RS="\"\n";IGNORECASE = 0}
    {
      if( $2 ~ se ) print $2;
    }' #}}}

elif [ "$1" = ts ]; then
#{{{#{{{
:<<HELP
 ts - full text search in dictionary. Example: enrutranslate.sh ts look
HELP
#}}}
	for file in `tar -tvzf $lang'translate.tar.gz'|awk '{print $6}'`;do
		ext="${file##*.}"
		#echo ext:$ext
		if [[ "$ext" =~ dic || ! "$ext" || ( "$ext" != txt && "$ext" != htm ) ]]; then continue; fi
		echo -n .
		if [ $ext = 'txt' ]; then 
			out=`tar -xzOf $lang'translate.tar.gz' "$file"|grep -i "$2"`
		else
			out=`getelinks "$file"|grep -i "$2"`
		fi
		if [[ -n $out ]] ; then
			echo -e "\n" $file: ""
			echo "$out"
		fi
	done #}}}

elif [ "$1" = t ]; then
	thesaurus "$1" "$2" "$3"

elif [ "$1"  = p ]; then
	pageout "$1" "$2" "$3" | sed -e '/^PAGEVAR$/,/^PAGEVAR$/d'

elif [ "$1" = a ]; then
#{{{#{{{
:<<HELP
 a - add a new page to dictionary. 
     Example: enrutranslate.sh a "look up" "look towards" dic/lookup.txt
     Where 3-d argument is an 'append after' index, ie append after "look towards".
HELP
#}}}
	#tar -xjOf $lang'translate.tar.bz2' toc.csv | \#{{{
	#unzip -c $lang'translate.zip' toc.csv | \#}}}
	tar -xzOf $lang'translate.tar.gz' toc.csv | \
	awk -v se="^$3" -v wo="$2" -v pg="$4" 'BEGIN{FS="\",\"|^\"|\"$";IGNORECASE = 0; ins=0}
    {
			print 
      if(ins==0 && $2 ~ se ){ print "\"" wo "\",\"" pg "\""; ins=1; }
		}' >toc.csv

	gzip -df $lang'translate.tar.gz'
	tar -r -f $lang'translate.tar' "$4" 
	tar --delete -f $lang'translate.tar' toc.csv
	tar -u -f $lang'translate.tar' toc.csv
	gzip $lang'translate.tar' 
	#}}}

elif [ "$1" = d ] ; then
#{{{#{{{
:<<HELP
 d - delete a page from dictionary. Example: enrutranslate.sh d "look up" dic/lookup.txt
HELP
#}}}
 	page=$(getpage "$2")
	tar -xzOf $lang'translate.tar.gz' toc.csv | \
	awk -v se="$2" 'BEGIN{FS="\",\"|^\"|\"$";IGNORECASE = 1; ins=0}
    {
      if(ins==0 && $2 == se )
			 	ins=1;
			else
				print;
		}' >toc.csv

	gzip -df $lang'translate.tar.gz'
	if tar -tvzf $lang'translate.tar.gz' |grep -q $page ;then
		tar --delete -f $lang'translate.tar' $page #$page
	fi
	tar --delete -f $lang'translate.tar' toc.csv
	tar -u -f $lang'translate.tar' toc.csv
	gzip $lang'translate.tar'
#}}}

elif [ "$1" = e ] || [ "$1"  = r ]; then
#{{{#{{{
:<<HELP
 r - replace a content from 'dic' directory.
     Example: enrutranslate.sh r "look up" dic/lookup.txt
 e - same as 'r' replace, but add a content from file in 'dic' to content in dictionary.
     Example: enrutranslate.sh e "look up" dic/lookup.txt
HELP
#}}}
	page=$(getpage "$2")
	tar -xzOf $lang'translate.tar.gz' toc.csv | \
	awk -v se="$2" -v pg="$3" 'BEGIN{FS="\",\"|^\"|\"$";IGNORECASE = 0; ins=0}
    {
      if(ins==0 && $2 == se ){ print "\"" $2 "\",\"" pg "\""; ins=1; }
			else
				print ;
		}' >toc.csv
	#debug :$1:$2:$#:$extension:
	filen=$page
	if ! tar -tvzf $lang'translate.tar.gz' |grep -q "$page" ;then
		ext="${page##*.}"
		test ext = htm && ext=txt || ext=htm 
		filen="${page%.*}.a.$ext"
	fi

	test "$1"  = e && (temp=`cat "$3"`;getelinks "$filen" >"$3"; echo "$temp" >> "$3")
	
	gzip -df $lang'translate.tar.gz'
	tar --delete -f $lang'translate.tar' "$filen" #$page
	tar -u -f $lang'translate.tar' "$3" #$page
	tar --delete -f $lang'translate.tar' toc.csv
	tar -u -f $lang'translate.tar' toc.csv
	gzip $lang'translate.tar'
#}}}

elif [ "$1" = l ]; then
#{{{#{{{
:<<HELP
 l - 'look up' mod - get new page by 'trans' app and add to content in dictionary.
     Example: enrutranslate.sh l peace
    'trans' (https://github.com/soimort/translate-shell) must be installed for this mod.
HELP
#}}}
	cnt=$(pageout "$1" "$2" "$3")
	if [[ ! -d dic ]];then mkdir dic; fi
	if [[ ! "$cnt" =~ 'There is no page' ]]; then
		page=`echo "$cnt"|awk '/PAGEVAR/{next}{print;exit 1}'`
		filen=${page%.*}.txt	
		echo "$cnt"| sed -e '/^PAGEVAR$/,/^PAGEVAR$/d'|tee $page.txt|tee $filen
		echo -----|tee -a $filen
		se=$2
		new=0
	else
		filen=${2// /-}
		filen="dic/$filen.txt"
		#filen=dic/${filen,,}.txt
		if [[ ${#2} -gt 3 ]]; then
			let ln=${#2}-3
			se=${2:0:$ln}
		else
			se="${2}"
		fi
		new=1
	fi
	cnt=`thesaurus "$1" "$2" "$3"`
	if [ -n "$cnt" ]; then
		echo "$cnt"|tee -a "$filen"
		echo -----|tee -a "$filen"
	fi
	trans :ru+en "$2" |tee -a $filen 
	
	tar -xzOf $lang'translate.tar.gz' toc.csv | \
	awk -v se="$se" -v pg="$filen" -v wo="$2" -v new="$new" 'BEGIN{FS="\",\"|^\"|\"$";IGNORECASE = 0; ins=0}
    {
      if(ins==0 && new==0 && $2 == se || new==1 && ins==0 && $2 ~ se){
				if(new==1) print
			 	print "\"" wo "\",\"" pg "\""; ins=1; 
			}
			else
				print;
		}' >toc.csv
	gzip -df $lang'translate.tar.gz'
	tar --delete -f $lang'translate.tar' "$page"
	tar -u -f $lang'translate.tar' "$filen"
	tar --delete -f $lang'translate.tar' toc.csv
	tar -u -f $lang'translate.tar' toc.csv
	gzip $lang'translate.tar'
#}}}

elif [ "$1" = diff ]; then
#{{{#{{{
:<<HELP
 diff - compare entries of toc.csv and pages in dictionary. Example: enrutranslate.sh diff
HELP
#}}}
	#debugging=1
	#toc=`tar -xzOf $lang'translate.tar.gz' toc.csv| 
			#awk 'BEGIN{FS="\",\"|^\"|\"$"; RS="\"\n";IGNORECASE = 0}
    #{print $3 }'`
	declare -A TOC LIST
	while read -r line; do
		TOC[$line]=1
	done <<<`tar -xzOf $lang'translate.tar.gz' toc.csv| 
			awk 'BEGIN{FS="\",\"|^\"|\"$"; RS="\"\n";IGNORECASE = 0}
    {print $3 }'`
	echo TOC:${#TOC[@]}:
	#read -p PressEnter

	while read -r line; do
		LIST[$line]=1
	done <<< `tar -tvzf $lang'translate.tar.gz'|grep -v dic/$ | grep dic/ |awk '{print $6}'`
	echo LIST:${#LIST[@]}:

	if [[ ${#TOC[@]} -lt ${#LIST[@]} ]];then
		for line in ${!LIST[@]};do
			if [[ ! ${TOC[$line]} ]]; then 
				echo
				echo There is no index for the page: $line
			else
				if [[ $diff -eq 1000 ]];then
					echo -n .
					diff=0
					#debug $line 
				fi
				(( diff++  ))
			fi
		done
	else
		for line in ${!TOC[@]};do
			if [[ ! ${LIST[$line]} ]]; then 
				echo
				echo There is no page for index search: $line
			else
				if [[ $diff -eq 1000 ]];then
					echo -n .
					diff=0
					#debug $line 
				fi
				(( diff++  ))
			fi
		done
	fi
	#while read -r line; do
		##echo "$toc" | grep	-q "$line"
		##grep  -q "$line" <<< "$toc"
		#if [[ ! ${TOC[$line]} ]]; then 
			#echo $line
		#else
			#if [[ $diff -eq 1000 ]];then
				#echo -n .
				#diff=0
				##debug $line 
			#fi
			#(( diff++  ))
		#fi
		#(( list++  ))
	#done <<< `tar -tvzf $lang'translate.tar.gz'|grep -v dic/$ | grep dic/ |awk '{print $6}'`
	#echo
	#echo list:$list:
#}}}

elif [ "$1" = b ]; then
#{{{#{{{
:<<HELP
 b - make a backup of dictionary. Example: enrutranslate.sh b
HELP
#}}}
	suf=`date +"%Y%m%d%H%M%S"`
	cp -f $lang'translate.tar.gz' $lang'translate-'$suf'.tar.gz'
#}}}

fi
cd - > /dev/null 2>&1

# vim: ts=2 sw=2 noet foldmethod=marker :
