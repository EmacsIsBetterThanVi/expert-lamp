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
	./.EXIT $1
    fi
    cd $1
    if ls -a | grep ".ENTRY" 2>&1 > /dev/null ; then
	./.ENTRY $PWD
    fi
}
function vccd(){
    local DIR
    DIR=$PWD
    if ls -a | grep ".EXIT" 2>&1 > /dev/null ; then
	./.EXIT $1
    fi
    cd $1
    if ls -a | grep ".ENTRY" 2>&1 > /dev/null ; then
	./.ENTRY $PWD
    fi
    shift
    ls $@
}
