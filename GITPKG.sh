function expert-lamp-install(){
MYDIR=$PWD
mkdir ~/.gitINSTALL
INSTALLED=false
cd ~/.gitINSTALL
if [[ $2 == "" ]] ; then
if git ls-remote https://github.com/EmacsIsBetterThanVi/expert-lamp.git | grep -e "refs/heads/$1" ; then
git clone -b "$1" --single-branch https://github.com/EmacsIsBetterThanVi/expert-lamp.git || exit 1
elif cat ~/.config/expert-lamp.pkglist | grep -e "-$1:" ; then
FOUND=false
for i in $(cat ~/.config/expert-lamp.srclist); do
if git ls-remote https://github.com/$i/expert-lamp.git | grep -e "refs/heads/$1" ; then
git clone -b "$1" --single-branch https://github.com/$i/expert-lamp.git || exit 1
fi
done
! FOUND && ((PKGREPO= $(cat ~/.config/expert-lamp.pkglist | grep -e "-$1:") && git clone ${PKGREPO#-$1:}) || exit 1)
else
exit 1
fi
elif [[ $2 == "local" ]]; then
git clone $1 || exit 1
else
git clone -b "/refs/head/$1" --single-branch https://github.com/$2/expert-lamp.git || exit 1
fi
[[ -d $1 ]] && cd $1 || cd expert-lamp
[[ -f install.sh ]] && ./install.sh && INSTALLED=true
[[ -f configure ]] && ./configure && INSTALLED=true
[[ -f CMakeLists.txt ]] && cmake
[[ -f Makefile ]] && make && make install && INSTALLED=true && make clean
if [[ -f INSTALL.generate ]]; then
generate install INSTALL && INSTALLED=true
generate clean
elif [[ -f $1.generate ]]; then
generate install $1 && INSTALLED=true
generate clean
else
for i in $(ls | grep ".generate"); do
generate install ${i%.generate} && INSTALLED=true
generate clean
done
fi
if $INSTALLED ; then
echo $1 >> ~/.config/expert-lampI.pkglist
whereis $1 >> ~/.config/expert-lampL.pkglist
fi
cd $MYDIR
rm -rf ~/.gitINSTALL
unset MYDIR
unset INSTALLED
unset PKGREPO
}
function expert-lamp-uninstall(){
INSTALLDIR=$(cat ~/.config/expert-lampL.pkglist | grep -e "$1:")
INSTALLDIR=${INSTALLDIR#$1:}
for i in $INSTALLDIR; do
rm -rf $i
done
sed -i '' "/$1/d" ~/.config/expert-lampI.pkglist
sed -i '' "/$1:/d" ~/.config/expert-lampL.pkglist
}
function expert-lamp-src(){
    if [[ $1 == add ]]; then
    echo $2 >> ~/.config/expert-lamp.srclist
    elif [[ $1 == del ]]; then
    sed -i '' "/$2/d" ~/.config/expert-lamp.srclist
    elif [[ $1 == list ]]; then
    cat ~/.config/expert-lamp.srclist
    fi
}
function expert-lamp-list(){
if [[ $1 == installed ]]; then
cat ~/.config/expert-lampI.pkglist
elif [[ $1 == locations ]]; then
cat ~/.config/expert-lampL.pkglist
elif [[ $1 == src ]]; then
cat ~/.config/expert-lamp.srclist
else
cat ~/.config/expert-lamp.pkglist
fi
}
function expert-lamp-update(){
MYDIR=$PWD
mkdir ~/.gitINSTALL
cd ~/.gitINSTALL
wget https://raw.githubusercontent.com/EmacsIsBetterThanVi/expert-lamp/main/PKGLIST
cat PKGLIST > ~/.config/expert-lamp.pkglist
for i in $(cat ~/.config/expert-lamp.srclist); do
wget https://raw.githubusercontent.com/EmacsIsBetterThanVi/expert-lamp/main/PKGLIST
cat PKGLIST >> ~/.config/expert-lamp.pkglist
done
nuke ~/.gitINSTALL
}
function lamp(){
LAMP=$1
shift
expert-lamp-$LAMP $@
}
