#!/bin/bash
export PATH="$HOME/.generated/:$PATH"
source ~/.generated/.jars
function generate() {
if [[ $1 == "clean" ]]; then
rm -rf $(cat generate.list)
rm -f generate.list
elif [[ $1 == "help" ]]; then
echo "A auto build tool, which identifies the lanuage required to compile a program"
echo "Usage: generate <subcommand or target>"
echo "Subcommands:"
echo "generate <file name> [OUTPUT path] [INPUT path]: compiles the target file name"
echo "link <output file> <output directory>: links all compiled files "
echo "built [-options] <file name> <output>: compiles the target file name, and links it into the out put file"
echo "options:"
echo "  d: creates a build directory in the output directroy"
echo "  o <directroy>: sets the directory to output to"
echo "  i <directory>: sets the directory to draw files from"
echo "mkdir <name>: creates a directory including in the generate file"
echo "sh <shell command>: runs a shell command(for use in generate scripts"
echo "make [target name] [target directory]: creates a generate target that compiles the contents of target director, the curent directory if not provided. If the name is not provided it creates the BUILD target which links to build, if the name is install it creates the INSTALL target "
elif [[ $1 == "build" ]]; then
OUT=$PWD
IN=$PWD
arg=$2
if [[ $arg == *"o"* ]]; then
shift
OUT=".$2"
fi
if [[ $arg == *"i"* ]]; then
shift
IN=".$2"
fi
if [[ $arg == *"d"* ]]; then
generate mkdir build $OUT
OUT="$OUT/build"
fi
if [[ $arg == "-"* ]]; then
shift
fi
MYDIR=$PWD
generate generate $2 $OUT $IN
generate link $3 $OUT
cd $MYDIR
elif [[ $1 == "mkdir" ]]; then
echo "$3/$2: $PWD" >> $HOME/.config/generate.dirs
if [[ ! -d $3/$2 ]]; then
mkdir $3/$2
else
TMPDIR=$PWD
cd $3/$2
generate clean
cd $TMPDIR
fi
echo "$3/$2/" >> generate.list
elif [[ $1 == "link" ]]; then
if [[ $3 != "" ]]; then
cd $3
fi
ls *.o 2> /dev/null
if [[ $? == 0 ]]; then
ld $(cat ~/.config/generate.config | grep -e "-arch") $(cat ~/.config/generate.config | grep -e "-syslibroot") *.o $(cat ~/.config/generate.config | grep -e "-l") -o $2
echo "$2" >> generate.list
fi
ls *.class 2> /dev/null
if [[ $? == 0 ]]; then
echo "Main-Class: $2" > Manifest.txt
jar -cfm $2.jar Manifest.txt *.class
echo "Manifest.txt" >> generate.list
echo "$2.jar" >> generate.list
fi
ls *.op 2> /dev/null
if [[ $? == 0 ]]; then
ld $(cat ~/.config/generate.config | grep -e "-arch") $(cat ~/.config/generate.config | grep -e "-syslibroot") *.op $(cat ~/.config/generate.config | grep -e "-l") -o $2
echo "$2" >> generate.list
fi
elif [[ $1 == "generate" ]]; then
if [[ $4 != ""  &&  $# > 3 ]]; then
cd $$4
fi
if [[ $3 == "" || $# < 3 ]]; then
OUT=$PWD
else
OUT=$3
fi
ls $2".c" 2> /dev/null
if [[ $? == 0 ]]; then
cc -c $2.c -o $OUT/$2.o $(cat ~/.config/generate.config | grep -e "-iquote")
echo "$2.o" >> $OUT/generate.list
fi
ls $2".cpp" 2> /dev/null
if [[ $? == 0 ]]; then
c++ -c $2.c -o $OUT/$2.opp $(cat ~/.config/generate.config | grep -e "-iquote")
echo "$2.o" >> $OUT/generate.list
fi
ls $2".java" 2> /dev/null
if [[ $? == 0 ]]; then
javac $2.java -d $OUT
echo "$2.class" >> $OUT/generate.list
fi
ls $2.pyx 2> /dev/null
if [[ $? == 0 ]]; then
cython --embed $2.pyx -o $OUT/$2.pyx.c
echo "$2.pyx.c" >> $OUT/generate.list
cc $OUT/$2.pyx.c -c $(cat ~/.config/generate.config | grep -e "-I") -o $OUT/$2.op
echo "$2.op" >> $OUT/generate.list
fi
ls $2.py 2> /dev/null
if [[ $? == 0 ]]; then
cython --embed $2.py -o $OUT/$2.py.c
echo "$2.py.c" >> $OUT/generate.list
cc $OUT/$2.py.c -c $(cat ~/.config/generate.config | grep -e "-I") $(cat ~/.config/generate.config | grep -e "-iquote") -o $OUT/$2.op
echo "$2.op" >> $OUT/generate.list
fi
elif [[ $1 == "sh" ]]; then
shift
$@
elif [[ $1 == "pkg" ]]; then
shift
generate.pkg $@
elif [[ $1 == "make" ]]; then
MAKETMPDIR=$PWD
if [[ $2 == "" ]]; then
TARGET="BUILD"
elif [[ $2 == "install" ]]; then
TARGET="INSTALL"
else
TARGET=$2
fi
if [[ $3 != "" ]]; then
cd $3
fi
echo "mkdir build ." > $TARGET.generate
for i in $(ls | grep -e ".c" -e ".java" -e ".pyx" -e ".cpp" -e ".py"); do
y=${i##*/}
y=${y%.c}
y=${y%.cpp}
y=${y%.java}
y=${y%.pyx}
y=${y%.py}
echo "generate $y ./build" >> $TARGET.generate
done
if [[ $2 == "install" ]]; then
if [[ $3 == "" ]]; then
echo "link ${PWD##*/} ./build" >> $TARGET.generate
else
echo "link ${3##*/} ./build" >> $TARGET.generate
fi
else
echo "link $TARGET ./build" >> $TARGET.generate
fi
echo "$TARGET.generate" >> generate.list
cd $MAKETMPDIR
elif [[ $1 == "install" ]]; then
MAKETMPDIR=$PWD
if [[ $2 != "" ]]; then
generate $2
fi
while [[ -d $(tail -n1 generate.list) ]]; do
cd $(tail -n1 generate.list)
done
if tail -n1 generate.list | grep ".jar"; then
cp $(tail -n1 generate.list) ~/.generated/jars
x=$(tail -n1 generate.list)
echo "alias ${x%.jar}='java -jar ~/.generated/jars/$x'" >> $HOME/.generated/.jars
alias ${x%.jar}="java -jar ~/.generated/jars/$x"
else
cp $(tail -n1 generate.list) ~/.generated/
echo $(tail -n1 generate.list) >> ~/.generated/.installed
fi
elif [[ $1 == "list" ]]; then
if [[ $2 == "installed" ]]; then
cat $HOME/.generated/.installed
for i in $(ls $HOME/.generated/jars); do
echo ${i%.jar}
done
elif [[ $2 == "generated" ]]; then
cat generate.list
elif [[ $2 == "trace" ]]; then
ls -a ~/*/*/*/*/*
elif [[ $2 == "recursive" ]]; then
MAKETMPDIR=$PWD
while [[ -d $(tail -n1 generate.list) ]]; do
echo $PWD:
cat generate.list
cd $(tail -n1 generate.list)
done
echo $PWD:
cat generate.list
cd $MAKETMPDIR
elif [[ $2 == "targets" ]]; then
for i in $(ls | grep ".generate"); do
echo ${i%.generate}
done
fi
elif [[ $1 == "uninstall" ]]; then
if cat ~/.generated/.installed | grep "$2"; then
sed -i '' "/$2/d" "$HOME/.generated/.installed"
rm -f ~/.generated/$2
elif cat ~/.generate/.jars | grep "alias $2"; then
sed -i '' "/^$2/d" "$HOME/.generated/.installed"
unalias $2
rm -f ~/.generated/jars/$2.jar
fi
else
ls | grep "$1.generate" > /dev/null
if [[ $? == 0 ]]; then
TARGETDIRECTORY=$PWD
while read i; do
  generate $i
done < $1.generate
cd $TARGETDIRECTORY
else
echo "Target $1 does not exist"
fi
fi
}
function generate.config(){
if test ! -d "$HOME/.config"; then
mkdir "$HOME/.config"
fi
if test ! -d "$HOME/.generated"; then
mkdir "$HOME/.generated"
echo "# DEPENDENCIES" > "$HOME/.generated/.deplist"
fi
if test ! -d "$HOME/.generated/jars"; then
mkdir "$HOME/.generated/jars"
echo "#!/bin/bash" > "$HOME/.generated/.jars"
fi
if [[ $(uname) == "Darwin" ]]; then
if cc -v 2>&1 | grep "clang"; then
echo "-arch $(uname -m)" > ~/.config/generate.config
echo "-I/usr/local/opt/python@3.12/Frameworks/Python.framework/Versions/3.12/include/python3.12 -I/usr/local/opt/python@3.12/Frameworks/Python.framework/Versions/3.12/include/python3.12" >> ~/.config/generate.config
echo "-iquote ~/.headers/" >> ~/.config/generate.config
echo "-syslibroot /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk" >> ~/.config/generate.config
echo "-lSystem /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/clang/15.0.0/lib/darwin/libclang_rt.osx.a" >> ~/.config/generate.config
echo "-L/usr/local/opt/python@3.12/Frameworks/Python.framework/Versions/3.12/lib/ -lpython3.12" >> ~/.config/generate.config
fi
if cc -v 2>&1 | grep "gcc"; then
echo "-A $(uname -m)" > ~/.config/generate.config
echo "--syslibroot /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk" >> ~/.config/generate.config
echo "-lSystem /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/clang/15.0.0/lib/darwin/libclang_rt.osx.a" >> ~/.config/generate.config
fi
fi
if [[ $(uname -r) == *arch* ]]; then
echo "--architecture $(uname -m)" > ~/.config/generate.config
echo "--plugin /usr/lib/gcc/i686-pc-linux-gnu/12.1.0/liblto_plugin.so -plugin-opt=/usr/lib/gcc/i686-pc-linux-gnu/12.1.0/lto-wrapper -plugin-opt=-fresolution=/tmp/ccISBgBd.res -plugin-opt=-pass-through=-lgcc -plugin-opt=-pass-through=-lgcc_s -plugin-opt=-pass-through=-lc -plugin-opt=-pass-through=-lgcc -plugin-opt=-pass-through=-lgcc_s --build-id --eh-frame-hdr --hash-style=gnu -m elf_i386 -dynamic-linker /lib/ld-linux.so.2 -pie /usr/lib/gcc/i686-pc-linux-gnu/12.1.0/../../../Scrt1.o /usr/lib/gcc/i686-pc-linux-gnu/12.1.0/../../../crti.o /usr/lib/gcc/i686-pc-linux-gnu/12.1.0/crtbeginS.o -L/usr/lib/gcc/i686-pc-linux-gnu/12.1.0 -L/usr/lib/gcc/i686-pc-linux-gnu/12.1.0/../../.. -lgcc --push-state --as-needed -lgcc_s --pop-state -lc -lgcc --push-state --as-needed -lgcc_s --pop-state /usr/lib/gcc/i686-pc-linux-gnu/12.1.0/crtendS.o /usr/lib/gcc/i686-pc-linux-gnu/12.1.0/../../../crtn.o" >> ~/.config/generate.config
fi
}
function generate.pkg(){
    if [[ $1 == "uninstall" ]]; then
        PKGLIST=$(cat "$HOME/.generated/.deplist" | grep -e "$2")
        if [[ $3 != "-f" ]]; then
        echo "Uninstalling $2 will remove the follwing packages:" ${PKGLIST%%:*}
        read -p "Continue?[y/N]" -n1 DEL
        else
        DEL=Y
        fi
        if [[ $DEL == [Yy] ]]; then
        rm -f $HOME/.generate/${{PKGLIST%%:*}#-}
        sed -i '' "/^${PKGLIST%%:*}/d" "$HOME/.generated/.deplist"
        for i in ${{PKGLIST%%:*}#-}; do
        generate.pkg uninstall $i -f
        done
        fi
    elif [[ $1 == "install" ]]; then
        if [[ $3 != "-f" ]]; then
        echo "Installing $2 will also install the following packages:" $(cat $2.deplist)
        read -p "Continue?[y/N]" -n1 DEL
        INSTALLROOT=$PWD
        if [[ $DEL == [Yy] ]]; then
        mkdir $HOME/.generateINSTALL
        cd $HOME/.generateINSTALL
        fi
        else
        DEL=Y
        fi
        if [[ $DEL == [Yy] ]]; then
        if [[ -d $INSTALLROOT/$2 ]]; then
        cp -r $INSTALLROOT/$2 .
        else
        $(echo ${(cat $HOME/.config/generate.pkglist | grep -e "-.*%:")#*%:} | sed -e 's/%/$2/g')
        ${(cat $HOME/.config/generate.pkglist | grep -e "-$2:")#-$2:}
        fi
        cd $2
        for i in $(cat $2.deplist); do
        generate.pkg install $i -f
        done
        generate install $2
        fi
        if [[ $3 != "-f" ]]; then
        rm -rf $HOME/.generateINSTALL
        cd $INSTALLROOT
        fi
    elif [[ $1 == "clean" ]]; then
    if [[ -d $HOME/.generateINSTALL ]]; then
    rm -rf $HOME/.generateINSTALL
    fi
    echo "-apt%: sudo apt install %" > $HOME/.config/generate.pkglist
    echo "-brew%: brew install %" > $HOME/.config/generate.pkglist
    fi
}
