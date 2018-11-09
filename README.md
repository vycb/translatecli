# translatecli 
It is a bash based script, engliah-russian and russian-engliah off-line dictionary,
wich allows to translate in console.  
engliah-russian - 48523 words  
russian-engliah - 45678 words  
Only dependense on: gawk, elinks and bz2  

Usage:  
# to search  
$ enrutranslate.sh script  
prescriptive  
proscription  
rescript  
script  
scriptoria  
scriptorium  
# Or  
$ enrutranslate.sh ^script   
script  
scriptoria  
scriptorium  
scriptural  
# Read page  
$ enrutranslate.sh p script  
   << scrip << script >> scriptoria >>  
  
   [skrɪpt]  
  
   01. noun  
   1) почерк  
  
Instalation:  
git clone --depth=1 https://github.com/vycb/translatecli.git  
  
Add enrutranslate.sh somewhere into PATH (~/bin)  
Create symbolic link ruentranslate.sh (for russian-engliah dictionary)  
For example: cd ~/bin; ln -s ~/bin/enrutranslate.sh  ~/bin/ruentranslate.sh  

$ enrutranslate.sh -h  
Usage:  
 pattern - to search dictionary. Example: enrutranslate.sh peace  
 ts - full text search in dictionary. Example: enrutranslate.sh ts look  
 a - add a new page to dictionary.   
     Example: enrutranslate.sh a "look up" "look towards" dic/lookup.txt  
     Where secon argument is a 'append after' index.  
 d - delete a page from dictionary. Example: enrutranslate.sh d "look up" dic/lookup.txt  
 r - replace a content from 'dic' directory.  
     Example: enrutranslate.sh r "look up" dic/lookup.txt  
 e - same as 'r' replace, but add a content from file in 'dic' to content in dictionary.  
     Example: enrutranslate.sh e "look up" dic/lookup.txt  
 l - 'look up' mod - get new page by 'trans' app and add to content in dictionary.  
     Example: enrutranslate.sh l peace  
    'trans' (https://github.com/soimort/translate-shell) must be installed for this mod.  
 diff - compare entries of toc.csv and pages in dictionary. Example: enrutranslate.sh diff  
 b - make a backup of dictionary. Example: enrutranslate.sh b  
  
$ ruentranslate.sh документ  
документ  
документальный  
документация  
  
$ ruentranslate.sh p документ  
   << докуда << документ >> документальный >>  
  
   noun  
   (m.)  
   document, paper;  
  

