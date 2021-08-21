#this shell adds keywords to MD files without keywords

IFS=`echo -en "\n\b"`

ROOTDIR=`dirname "$0"`
ROOTDIR=`cd "$ROOT"; pwd`

scandir() {
    for file in `ls $*`; do
        if [[ ! -d $*"/"$file ]]; then
            if [[ $file == *".md" ]]; then
                readfile $*"/"${file}
            fi
        else
            scandir $*"/"${file}
        fi
    done
}

readfile() {
    local file=$*
    local topic=`cat $file | grep "^#[^#].*" | grep -o "[^# ]\+\( \+[^ ]\+\)*"`
    local keywordNum=`cat $file | grep "^##[^#]*keyword[ ]*$" | wc -l`
    if [[ $keywordNum != 0 || -z $topic ]]; then
        return
    fi
    local SAVEIFS=$IFS
    IFS=' '
    local array=`echo $topic | tr '\`' ' ' | tr ',' ' '`
    local keywords=
    for keyword in ${array[*]}; do
        keywords=$keywords"\n"$keyword
    done
    array=`echo $array | tr '_' ' '`
    for keyword in ${array[*]}; do
        keywords=$keywords"\n"$keyword
    done
    keywords=`echo -en ${keywords} | tr 'a-z' 'A-Z' | uniq | tr "\n" ","`
    keywords=${keywords#,}
    keywords=${keywords%,}
    IFS=$SAVEIFS
    file=`echo $file | sed 's/[ \(\)]/\\\&/g'`
    eval sed -i '"\$a ##keyword"' $file
    eval sed -i '"\$a ${keywords}"' $file
}

main() {
    scandir $ROOTDIR
}

main "$@"
exit 0
