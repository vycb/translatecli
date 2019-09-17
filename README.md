# translatecli  

Bash based off-line dictionary for translation English-Russian and Russian-English in Linux terminal.  
English-Russian - 48523 words  
Russian-English - 45678 words  
Only dependent's on: awk, elinks and tar gz  
  
The dictionaries originally ported from chm files.  
There was a 'Far'-file manager's plugin project. Thanks to the authors.  
There are additional 3-e pages in the en-ru dictionary:  
dobropogalovat  
blagodarnost  
transkripcia  
 
 
## Usage:  
#### to search  
$ enrutranslate.sh script  
prescriptive  
proscription  
rescript  
script  
scriptoria  
scriptorium  
#### Or  
$ enrutranslate.sh ^script   
script  
scriptoria  
scriptorium  
scriptural  
#### Read page  
$ enrutranslate.sh p script  
   << scrip << script >> scriptoria >>  
  
   [skrɪpt]  
  
   01. noun  
   1) почерк  
		
$ ruentranslate.sh документ  
документ  
документальный  
документация  
  
$ ruentranslate.sh p документ  
   << докуда << документ >> документальный >>  
  
   noun  
   (m.)  
   document, paper;  
   
### Instalation:  
Download and install the Git command line extension. You only have to set up Git LFS once.  
git lfs install  
git clone --depth=1 https://github.com/vycb/translatecli.git   
Add enrutranslate.sh somewhere into PATH (~/bin)  
Create symbolic link ruentranslate.sh (for russian-engliah dictionary)  
For example: cd ~/bin; ln -s ~/bin/enrutranslate.sh  ~/bin/ruentranslate.sh 
Add to .bashrc path of cloned repo. For example: export TRANSLATECLI_HOME="$HOME/.vim/doc/translatecli"  
For look up mod 'trans' application should be installed. See https://github.com/soimort/translate-shell.   
Also, to lookup in thesaurus.altervista.org, we need to register there, and add reg-key in .config file.  
  
$ enrutranslate.sh -h  
Usage:  
 pattern - to search dictionary. Example: enrutranslate.sh peace  
 ts - full text search in dictionary. Example: enrutranslate.sh ts look  
 p - get read a page in dictionary. Example: enrutranslate.sh p "look up"  
 a - add a new page to dictionary.   
     Example: enrutranslate.sh a "look up" "look towards" dic/lookup.txt  
     Where 3-d argument is an 'append after' index, ie append after "look towards".  
 d - delete a page from dictionary. Example: enrutranslate.sh d "look up" dic/lookup.txt  
 r - replace a content from 'dic' directory.  
     Example: enrutranslate.sh r "look up" dic/lookup.txt  
 e - same as 'r' replace, but add a content from file in 'dic' to content in dictionary.  
     Example: enrutranslate.sh e "look up" dic/lookup.txt  
 l - 'look up' mod - get new page by 'trans' app and add to content in dictionary.  
     Example: enrutranslate.sh l peace  
    'trans' (https://github.com/soimort/translate-shell) must be installed for this mod.  
 diff - compare entries of toc.csv and pages in dictionary. Example: enrutranslate.sh diff  
 b - backup a dictionary. Example: enrutranslate.sh b   
  

