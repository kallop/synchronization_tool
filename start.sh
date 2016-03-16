#!/bin/bash
function default_tools() {
     repo sync --force-broken -j32
     while [ $? == 1 ]; do
        echo "======sync failed, re-sync again======"
        repo sync --force-broken -j32
     done
}

function kallop_tools() {
     ALL_PKG=`grep project .repo/manifest.xml |awk '{print $3}' |cut -d'"' -f2`
     ERR_PKG=""
     RUN_ERR_PKG=`cat synchronization_tool/fail.pkg`
     T_PKG=$ALL_PKG

     while [ 1 ]
     do
       for i in $T_PKG
       do
           grep "$i" synchronization_tool/success.pkg >/dev/null 2>&1
           if [ $? -eq 0 ]; then
               continue
           fi
           repo sync $i -j32
           if [ $? -ne 0 ];then
               echo "SYNC Error $i"
               ERR_PKG="$ERR_PKG $i"
               grep "$i" synchronization_tool/fail.pkg >/dev/null 2>&1
               if [ $? -ne 0 ]; then
                   echo "$i" >> synchronization_tool/fail.pkg
               fi
               continue
           else
               grep "$i" synchronization_tool/success.pkg >/dev/null 2>&1
               if [ $? -ne 0 ]; then
                   echo "$i" >> synchronization_tool/success.pkg
               fi
               echo "SYNC Success $i"
           fi
       done

       if [ "$ERR_PKG" = "" ];then
           echo "SYNC ALL"
           for i in $RUN_ERR_PKG
           do
             echo "$i"
       done
           exit 0
       else
           T_PKG=$ERR_PKG
           ERR_PKG=""
       fi
     done
}

function choose_tools() {
     echo ""
     echo "     Welcome to use Kallop Android synchronization tool"
     echo ""
     echo "1. use the default tools                2. use of new kallop tools"
     echo "Q. quit"
     echo ""
     read -p "Please choose your way [1..2, Q] ? " i
     case "$i" in
             1)
               default_tools;
             ;;
             2)
               kallop_tools;
             ;;
             *)
               exit 0

     esac
}

choose_tools;
