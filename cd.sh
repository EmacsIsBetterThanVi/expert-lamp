#!/bin/bash
function vcd(){
    cd $1
    shift
    ls $@
}
function ccd(){
    local DIR
    DIR=$PWD
    if ls -a | grep ".EXIT" 2>&1 > /dev/null ; then
	source .EXIT $1
    fi
    cd $1
    if ls -a | grep ".ENTRY" 2>&1 > /dev/null ; then
	source .ENTRY $DIR
    fi
}
function vccd(){
    local DIR
    DIR=$PWD
    if ls -a | grep ".EXIT" 2>&1 > /dev/null ; then
	source .EXIT $1
    fi
    cd $1
    if ls -a | grep ".ENTRY" 2>&1 > /dev/null ; then
	source .ENTRY $DIR
    fi
    shift
    ls $@
}
