#!/bin/bash


LOCK_FILE=script.lock
if  [ -f $LOCK_FILE ] && kill -0 `cat $LOCK_FILE` >/dev/null 2>/dev/null && ps -p `cat $LOCK_FILE` -o cmd | grep `basename $0` >/dev/null 2>/dev/null
then 
echo instance of script is work
exit 2
else echo $$ >$LOCK_FILE
echo start work `date`
fi



echo "find oldfile active set false:"
rawresult=`mysql -u****** -p****** informator -se "UPDATE main_calls SET is_active = "false"  WHERE datecreate<=ADDDATE(NOW(),INTERVAL -10 MINUTE) AND is_active = "true""`
resultsql=$?
#echo $resultsql
#echo $rawresult


echo "call to:"
rawresult=`mysql -u****** -p****** informator -se "SELECT * FROM main_calls WHERE is_active="true" ORDER BY datecreate limit 1"`
resultsql=$?
#echo $resultsql
#echo $rawresult


read -a resultarray <<< "$rawresult";

 id="${resultarray[0]}"
 orderID="${resultarray[1]}"
 agent="${resultarray[2]}"
 callnumber="${resultarray[3]}"
 kod="${resultarray[4]}"
 status="${resultarray[5]}"
 typemsg="${resultarray[6]}"
 active="${resultarray[7]}"
 datecreate="${resultarray[8]} ${resultarray[9]}"
kws=`echo $kod | grep -Eo '.{1}' | tr "/r" " "` 
dateunow=`date +%s`
unixtimecreate=`date -d "$datecreate" "+%s"`

echo id = $id
echo orderID = $orderID
echo agent = $agent
echo callnumber = $callnumber
echo kod with separator = $kws
echo status= $status
echo typemsg= $typemsg
echo active = $active
echo datecreate = $datecreate
let dtime=$dateunow-$unixtimecreate

if [ $dtime -ge 600 ] ; then
 echo oldfile
 else 
 echo newfile
fi
if [ -z "$id" ]; then
   echo no calls needed
   exit 0;
fi


echo calls needed for id  = $id

if pidof linphonec; then
   pidlin=$(pidof linphonec)
   echo kill linphonec
   kill -2 $pidlin
   sleep 5
   if pidof linphonec; then
   pidlin = pidof linphonec
   kill -9 $pidlin
   fi
fi

	
./playe.sh $files $callnumber $kws
exitcode=$?


case "$exitcode" in
   1 ) echo "call";;
   2 ) echo "dontcall";;
   3 ) echo "user listen audio kode";;
   4 ) echo "user press repeat";;
   5 ) echo "user is busy";;
   6 ) echo "answered ";;
   7 ) echo "user do not hangup";;
 10 ) echo "call failed "
esac

echo "change status:"
rawresult=`mysql -u******* -p******** informator -se "UPDATE main_calls SET is_active = "false",status =$exitcode  WHERE id =$id"`
resultsql=$?
echo $resultsql
echo $rawresult

exit 0
