#!/bin/bash
#
# Ivan Shcherbak <dev@funivan.com> 2013
#

init (){

  REGEX='^[A-Z]+[-0-9a-zA-Z]*$'
  HELP="
    first argument  - author namespace
    second argument - library namespace

    ./init.sh Fiv Parser

    validation regex for names : $REGEX
  ";


  if [ -z $2 ] ; then
    echo "$HELP";
    return ;
  fi;


  if grep $REGEX <<<$1 ; then
    echo "invalid author namespace"
    return ;
  fi

  if grep $REGEX <<<$2 ; then
    echo "invalid library namespace"
    return ;
  fi

  echo "";
  echo "author namespace  : $1";
  echo "library namespace : $2";


  CURRENT_DIR=`pwd`;
  SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


  declare -A repalceNames;

  repalceNames["FivNamespace"]="$1";
  repalceNames["DemoProject"]="$2";
  repalceNames["fivnamespace"]=`echo $1 | tr '[:upper:]' '[:lower:]'`
  repalceNames["demoproject"]=`echo $2 | tr '[:upper:]' '[:lower:]'`


  # go to script dir
  cd $SCRIPT_DIR;

  for f in $(find "." -name "*" ! -name 'name.sh' | sort -r ); do

    newFilePath=$f;

    for from in "${!repalceNames[@]}";  do
      to=${repalceNames[$from]}

      # replace in file content;
      if [ -f $f ]; then
        sed -i "s/$from/$to/g" $f
      fi

      # replace in name.
      newFilePath=`echo $newFilePath | sed "s/$from/$to/g"`;

    done

    # ranme files
    if [[ -f $f || -d $f ]] && [  "$f" != "$newFilePath" ]; then

        echo "";
        echo "rename:";
        echo $f;
        echo $newFilePath;

        mkdir -p `dirname $newFilePath`;
        mv $f $newFilePath
    fi;

  done;

  # find empty folders with old names and remove it

  echo "";
  echo "---";
  for directory in $(find "." -type d -name "*" -empty | sort -r ); do
    for from in "${!repalceNames[@]}";  do
     if [[ "$directory" == *"$from"* ]]; then
      echo "remove old directory:$directory";
      rm -rf $directory/;
      break;
     fi;
    done;
  done;


  rm -rf .git/

  # partial git configuration

  echo "/tests export-ignore
.gitattributes export-ignore
.gitignore export-ignore" > .gitattributes;
  echo ".idea/
vendor/" > .gitignore;


  if [ -f userInit.sh ] ; then
    echo "Run user configuratin";
    source userInit.sh
  fi;


  echo "";
  echo "Remove your script and run composer update. Have fun =)";

  # go to current run directory
  cd $CURRENT_DIR;

  return 0;
}

init $@;
