if ! [[ $REFRESH ]] ; then
echo "function sourceall(){
for i in \$@; do
    source \$i
done
}
alias refresh=\"sourceall ~/.scripts/*\"
refresh
alias nuke=\"rm -rf\"
REFRESH=true" >> ~/.bash_profile
echo "function sourceall(){
for i in \$@; do
    source \$i
done
}
alias refresh=\"sourceall ~/.scripts/*\"
refresh
alias nuke=\"rm -rf\"
REFRESH=true" >> ~/.bash_alias
function sourceall(){
for i in $@; do
    source $i
done
}
alias refresh="sourceall ~/.scripts/*"
alias nuke="rm -rf"
REFRESH=true
fi
[[ -d ~/.config ]] || mkdir ~/.config
[[ -d ~/.scripts ]] || mkdir ~/.scripts
mv cd.sh ~/.scripts
for i in $(ls ~/.scripts/*); do
    source $i
done
