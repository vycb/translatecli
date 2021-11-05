#! /bin/bash -
#. /home/bin/bashruntime.sh

GZ='zstd --rm' #gzip
ZE=zst

if [ $# -eq 0 -o  "$1" = 'h' -o  "$1" = '-h'  -o "$1" = '--help' ];then
	#awk '/HELP$/{H=1;}; /^HELP$/{H=0}; !/HELP$|^HELP$/{if(H){print}}' "$0" #{{{
  sed -n '/^:<<HELP$/,/^HELP$/{//!p}' "$0"  #/HELP$/d
 	exit 0;
:<<HELP
Usage: enrutranslate.sh dictionary - to translate a word
HELP
	exit 0
fi #}}}

: ${TRANSLATECLI_HOME:="$HOME/.vim/doc/englishtranslate"}

urlencode(){
	awk 'BEGIN {while (y++ < 125) zword[sprintf("%c", y)] = y} #{{{
	{while (y = substr($0, ++j, 1))
		q = y ~ /[A-Za-z0-9_.!~*\47()-]/ ? q y : q sprintf("%%%02X", zword[y])
		print q}'
} #}}}

getpage(){
	#tar -xjOf $lang'translate.tar.bz2' toc.csv | \#{{{#{{{
	#unzip -c $lang'translate.zip' toc.csv | \#}}}
	tar -xOf $lang'translate.tar.'$ZE toc.csv | \
	awk -v se="${1}" 'BEGIN{FS="\",\"|^\"|\"$"; RS="\"\n";IGNORECASE = 1}
    {
			#tmp=match($2, se)
      #if( tmp )
      if($2 == se)
				{ print $3; exit 0;}
		}'
} #}}}

getelinks(){
#{{{
( elinks -no-references -no-numbering -dump )<  \
    <(tar -xOf $lang'translate.tar.'$ZE "$1")
} #}}}

pageout(){
#{{{
 	page=$(getpage "$2")
	if [[ ! $page ]]; then echo There is no page $2 ; exit 0; fi
	extension="${page##*.}"
	#debug :$1:$2:$#:$extension:
	echo -e "PAGEVAR\n$page\nPAGEVAR"
	if [ $extension = 'txt' ]; then
		tar -xOf $lang'translate.tar.'$ZE "$page"
	else
		getelinks "$page"
	fi
} #}}}

thesaurus(){
#{{{
	cmd='curl -s -c /tmp/lynxcookies'
	apikey=`awk -F= '/thesaurus.altervista.org/{print substr($0,index($0,"=")+1)}' .config` #
	word=`echo "$2" |urlencode`
	language='en_US'
	url='http://thesaurus.altervista.org/thesaurus/v1?word='$word'&language='$language'&key='$apikey'&output=xml'
	#echo $url
	#cat tezauras.xml|
	echo $($cmd -A 'Mozilla/5.0 (X11; CrOS x86_64 19999.999) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.9999 Safari/537.36' -L -b "Accept-Encoding=gzip,deflate;Host=thesaurus.altervista.org;__cfduid=df62b33881797a9df54020dfc579c21d11539243258;Accept=text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8" $url)|\
	awk -v se="$2" -f getXML.awk -f thesaurusaltervista.awk
} #}}}

[[ $0 =~ enru* ]] &&	lang='enru' || lang='ruen'
#  echo $lang arglen:$#
cd $TRANSLATECLI_HOME #> /dev/null 2>&1

if [[ $# -eq 1 ]] && [ "$1" != b ] &&  [ "$1" != diff ] && [ "$1" != cd ]; then
	mode=p #{{{
else
	mode=$1
fi  #}}}

case $mode in
	s|se)
#{{{#{{{
:<<HELP
s/se - to search in dictionary. Example: enrutranslate.sh s peace
HELP
#}}}
    #debug :$1:$2:$#:
    #unzip -c $lang'translate.zip' toc.csv | \#{{{
    #tar -xjOf $lang'translate.tar.bz2' toc.csv | \#}}}
    tar -xOf $lang'translate.tar.'$ZE toc.csv | \
			awk -v se="$2" 'BEGIN{FS="\",\"|^\"|\"$"; RS="\"\n";IGNORECASE = 0}
    {
      if( $2 ~ se ) print $2;
    }'
			;; #}}}

	g|gr)
#{{{#{{{
:<<HELP
g/gr - grep dictionary file archive and content of toc.csv. Example: enrutranslate.sh g look
HELP
#}}}
	tar -xOf $lang'translate.tar.'$ZE toc.csv |grep -i "$2"
	tar -tvf $lang'translate.tar.'$ZE |grep -i "$2"
#}}}
		;;

	ts)
#{{{#{{{
:<<HELP
ts - full text search in dictionary. Example: enrutranslate.sh ts look
HELP
#}}}
	for file in `tar -tvzf $lang'translate.tar.'$ZE|awk '{print $6}'`;do
		ext="${file##*.}"
		#echo ext:$ext
		if [[ "$ext" =~ dic || ! "$ext" || ( "$ext" != txt && "$ext" != htm ) ]]; then continue; fi
		echo -n .
		if [ $ext = 'txt' ]; then
			out=`tar -xzOf $lang'translate.tar.'$ZE "$file"|grep -i "$2"`
		else
			out=`getelinks "$file"|grep -i "$2"`
		fi
		if [[ -n $out ]] ; then
			echo -e "\n" $file: ""
			echo "$out"
		fi
	done #}}}
		;;

	tl)
#{{{{{{
:<<HELP
tl - transliterate the word. Example: enrutranslate.sh tl "look up"
HELP
#}}}
	case $lang in
		enru)
			sed -e 'y/abvgdjzijcklmnoprstufhyee/абвгджзийкклмнопрстуфхыэе/' -e 'y/ABVGDJZIJKLMNOPRSTUFHYEE/АБВГДЖЗИЙКЛМНОПРСТУФХЫЭЕ/' -e 's/yo/ё/gi; s/ts/ц/gi; s/ch/ч/gi; s/sh/ш/gi; s/sh/щ/gi; s/yu/ю/gi; s/ya/я/gi' <<< "$2"
			;;
		ruen)
			sed -e 'y/абвгджзийклмнопрстуфхыэе/abvgdjzijklmnoprstufhyee/' -e 'y/АБВГДЖЗИЙКЛМНОПРСТУФХЫЭЕ/ABVGDJZIJKLMNOPRSTUFHYEE/' -e 's/[ьъ]//gi; s/ё/yo/gi; s/ц/ts/gi; s/ч/ch/gi; s/ш/sh/gi; s/щ/sh/gi; s/ю/yu/g; s/я/ya/gi'<<< "$2"
			;;
	esac #}}}
	;;

	tr*)
#{{{{{{
:<<HELP
tr/tro -translate online with trans :ru+en. Example: enrutranslate.sh tr "look up"
HELP
#}}}
		trans :ru+en "$2" #}}}
		;;

	th*)
#{{{{{{
:<<HELP
th/the - search the word in thesaurus. Example: enrutranslate.sh t "look up"
HELP
#}}}
	thesaurus "$1" "$2" "$3" #}}}
		;;

	a)
#{{{#{{{
:<<HELP
a - add a new page to dictionary.
    Example: enrutranslate.sh a "look up" "look towards" dic/lookup.txt
    Where 3-d argument (optional) is an 'append after' index, ie append after "look towards".
HELP
#}}}
#tar -xjOf $lang'translate.tar.bz2' toc.csv | \#{{{
#unzip -c $lang'translate.zip' toc.csv | \#}}}
	if [[ $# -lt 4 ]]; then
      #let ln=${#2}-3
      se=${2:0:3}
			pg="$3"
  else
      se="$3"
			pg="$4"
  fi
	$GZ -df $lang'translate.tar.'$ZE
	tar -xOf $lang'translate.tar' toc.csv | \
	awk -v se="^$se" -v wo="$2" -v pg="$pg" 'BEGIN{FS="\",\"|^\"|\"$";IGNORECASE=0; ins=0}
    {
			print
      if(ins==0 && $2 ~ se ){ print "\"" wo "\",\"" pg "\""; ins=1; }
		}' >toc.csv

	tar --delete -f $lang'translate.tar' toc.csv
	tar -u -f $lang'translate.tar' toc.csv
	tar -r -f $lang'translate.tar' "$pg"
	$GZ $lang'translate.tar'
	#}}}
		;;

	d)
#{{{#{{{
:<<HELP
d - delete a page from dictionary. Example: enrutranslate.sh d "look up" dic/lookup.txt
    A 3-d argument is optional, it's need in case if there is no entry in index file toc.csv
HELP
#}}}
 	page=$(getpage "$2")
	tar -xzOf $lang'translate.tar.$ZE' toc.csv | \
	awk -v se="$2" 'BEGIN{FS="\",\"|^\"|\"$";IGNORECASE = 1; ins=0}
    {
      if(ins==0 && $2 == se )
			 	ins=1;
			else
				print;
		}' >toc.csv

	if [ "$page" == "" ]; then
		echo 1:"$page"
		page="$3"
		echo 2:"$page"
	fi
	$GZ -df $lang'translate.tar.$ZE'
	if tar -tvf $lang'translate.tar' |grep -q $page ;then
		tar --delete -f $lang'translate.tar' $page #$page
	fi
	tar --delete -f $lang'translate.tar' toc.csv
	tar -u -f $lang'translate.tar' toc.csv
	$GZ $lang'translate.tar'
#}}}
		;;

	e|r)
#{{{#{{{
:<<HELP
r - replace a content from 'dic' directory.
    Example: enrutranslate.sh r "look up" dic/lookup.txt
e - same as 'r' replace, but add a content from file in 'dic' to content in dictionary.
    Example: enrutranslate.sh e "look up" dic/lookup.txt
HELP
#}}}
	page=$(getpage "$2")
	tar -xzOf $lang'translate.tar.'$ZE toc.csv | \
	awk -v se="$2" -v pg="$3" 'BEGIN{FS="\",\"|^\"|\"$";IGNORECASE = 0; ins=0}
    {
      if(ins==0 && $2 == se ){ print "\"" $2 "\",\"" pg "\""; ins=1; }
			else
				print ;
		}' >toc.csv
	#debug :$1:$2:$#:$extension:
	filen=$page
	if ! tar -tvzf $lang'translate.tar.'$ZE |grep -q "$page" ;then
		ext="${page##*.}"
		test ext = htm && ext=txt || ext=htm
		filen="${page%.*}.a.$ext"
	fi

	test "$1"  = e && (temp=`cat "$3"`;getelinks "$filen" >"$3"; echo "$temp" >> "$3")

	$GZ -df $lang'translate.tar.'$ZE
	tar --delete -f $lang'translate.tar' "$filen" #$page
	tar -u -f $lang'translate.tar' "$3" #$page
	tar --delete -f $lang'translate.tar' toc.csv
	tar -u -f $lang'translate.tar' toc.csv
	$GZ $lang'translate.tar'
#}}}
		;;

	l)
#{{{#{{{
:<<HELP
l - 'look up', allows add or extend page from online by 'trans' an application.
    Example: enrutranslate.sh l peace
   'trans' (https://github.com/soimort/translate-shell) must be installed for this mode
HELP
#}}}
	cnt=$(pageout "$1" "$2" "$3")
	if [[ ! -d dic ]];then mkdir dic; fi
	if [[ ! "$cnt" =~ 'There is no page' ]]; then
		page=$(echo "$cnt"|awk '/PAGEVAR/{next}{print;exit 1}')
		filen=${page%.*}.txt
# 		filen=${filen/\.htm/}.txt
		echo "$cnt"| sed -e '/^PAGEVAR$/,/^PAGEVAR$/d'|tee $filen
		echo -----|tee -a $filen
		se=$2
		new=0
	else
		# This is a new page, then add same as add mode
		filen=${2// /-}
		filen="dic/$filen.txt"
		if [[ ${#2} -gt 3 ]]; then
			#let ln=${#2}-3
			se=${2:0:3}
		else
			se="${2}"
		fi
		new=1
	fi
	cnt=$(thesaurus "$1" "$2" "$3")
	if ! grep -q 'unexpected close tag'<<<"$cnt" && [[ -n $cnt ]]; then
		echo "$cnt"|tee -a "$filen"
		echo -----|tee -a "$filen"
	fi
	trans :ru+en "$2" |tee -a $filen

	tar -xOf $lang'translate.tar.'$ZE toc.csv | \
	awk -v se="$se" -v pg="$filen" -v wo="$2" -v new="$new" 'BEGIN{FS="\",\"|^\"|\"$";IGNORECASE = 0; ins=0}
    {
      if(ins==0 && new==0 && $2 == se || new==1 && ins==0 && $2 ~ se){
				if(new==1) print;
			 	print "\"" wo "\",\"" pg "\""; ins=1;
			}
			else
				print;
		}' >toc.csv
	$GZ -df $lang'translate.tar.'$ZE
	tar --delete -f $lang'translate.tar' "$page"
	tar -u -f $lang'translate.tar' "$filen"
	tar --delete -f $lang'translate.tar' toc.csv
	tar -u -f $lang'translate.tar' toc.csv
	$GZ $lang'translate.tar'
#}}}
		;;

	diff)
#{{{#{{{
:<<HELP
diff - compare entries of toc.csv and pages in dictionary. Example: enrutranslate.sh diff
HELP
#}}}
	#debugging=1
	#toc=`tar -xzOf $lang'translate.tar.$ZE' toc.csv|
			#awk 'BEGIN{FS="\",\"|^\"|\"$"; RS="\"\n";IGNORECASE = 0}
    #{print $3 }'`
	declare -A TOC LIST
	while read -r line; do
		TOC[$line]=1
	done <<<`tar -xzOf $lang'translate.tar.'$ZE toc.csv|
			awk 'BEGIN{FS="\",\"|^\"|\"$"; RS="\"\n";IGNORECASE = 0}
    {print $3 }'`
	echo TOC:${#TOC[@]}:
	#read -p PressEnter

	while read -r line; do
		LIST[$line]=1
	done <<< `tar -tvzf $lang'translate.tar.'$ZE|grep -v dic/$ | grep dic/ |awk '{print $6}'`
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
	#done <<< `tar -tvzf $lang'translate.tar.$ZE'|grep -v dic/$ | grep dic/ |awk '{print $6}'`
	#echo
	#echo list:$list:
#}}}
		;;

	b)
#{{{#{{{
:<<HELP
b - make a backup of dictionary. Example: enrutranslate.sh b
HELP
#}}}
	suf=`date +"%Y%m%d%H%M%S"`
	cp -f $lang'translate.tar.'$ZE $lang'translate-'$suf'.tar.'$ZE
#}}}
		;;

	cd)
#{{{{{{
:<<HELP
cd - change path to a dictionary directory. Example: . enrutranslate.sh cd
     Notice a dot befor the command
HELP
#}}}
		cd $TRANSLATECLI_HOME
		#}}}
		;;

	p|*)
#{{{{{{
:<<HELP
p - read a page from dictionary. Example: enrutranslate.sh p "look up", p - may be skiped
    just enrutranslate.sh "look up"
HELP
#}}}
		if [[ $1 = p ]];then shift; fi
		pageout "$mode" "$1" "$2" | sed -e '/^PAGEVAR$/,/^PAGEVAR$/d' #}}}
		;;


esac

cd - > /dev/null 2>&1

# vim: ts=2 sw=2 noet foldmethod=marker :
