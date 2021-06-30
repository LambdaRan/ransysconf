#!/bin/sh
# fix expect rz
export LC_CTYPE=en_US
cd "`dirname $0`"
BASE_HOME=`pwd`

if [ $# -ne 6 ];then
    echo "请检查hosts文件，格式为host user password ext."
    exit 1
fi

relayUser=$1
relayHost=$2
host=$3
user=$4
password=$5
ext=$6
echo $host , $user , $password, $relayHost, $relayUser, $ext
${HOME}/lambda/software/auto_login.exp $host $user $password $relayHost $relayUser $ext

