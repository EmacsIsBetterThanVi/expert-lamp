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
function sourceall(){
for i in $@; do
    source $i
done
}
alias refresh="sourceall ~/.scripts/*"
refresh
alias nuke="rm -rf"
REFRESH=true
fi
[[ -d ~/.config ]] || mkdir ~/.config
[[ -d ~/.scripts ]] || mkdir ~/.scripts
mv GITPKG.sh ~/.scripts
refresh
touch ~/.config/expert-lamp.srclist
touch ~/.config/expert-lampI.pkglist
touch ~/.config/expert-lampL.pkglist
lamp update
