########################################################################
# Copyright (c) CEP Research Institude, All rights reserved. Since 2008
#    Kage Park <kagepark@cep.kr>
#$version$:0.1.10
# Description :
########################################################################
KTAG=".k"
# _k_  : Kage function
# _kv_  : Kage variable

#include k.k

_k_mac_help() {
  echo "
  Convert MAC to integer 
  Convert integer to MAC

  $(basename $0) [<opt> [<input>] ]

  --help : help
  -m <mac address> : convert <mac address> to int64
  -i <int64>       : convert <int64> to <mac address>
  "
  exit
}

# base starting sample
_k_mac() {
   local cmd rcmd opt
   echo $1 | grep "^-" >& /dev/null || cmd=$1
   declare -F _k_${name}_${cmd} >& /dev/null && shift 1

   opt=("$@")
   if _k_opt --help 0 0 "${opt[@]}" >/dev/null; then
       _k_mac_help
       exit 0
   elif test=$(_k_opt -m 1 0 "${opt[@]}"); then
      _k_mac_str2mac $test || return 1
   elif test=$(_k_opt -i 1 0 "${opt[@]}"); then
      _k_mac_mac2str $test || return 1
   else
      echo "Unknown option"
      exit 1
   fi
}

_k_mac_str2mac () {
   [ -n "$1" ] || return 1
   let mac=0x$(echo $1| sed "s/://g")
   echo $mac
}

_k_mac_mac2str () {
   local str
   [ -n "$1" ] || return 1
   str=$(printf "%02X" $1)
   end=${#str}

   for ((ii=5;ii>=0;ii--)); do
      start=$(($end-1))
      if (($end >= 2 )); then
          mac_arr[$ii]=$(echo $str | cut -c ${start}-${end})
      elif (($end < 2 && $end > 0)); then
          mac_arr[$ii]=$(echo "0$(echo $str | cut -c -1)")
      else
          mac_arr[$ii]="00"
      fi
      end=$(($start-1))
   done
   echo ${mac_arr[*]}|sed "s/ /:/g"
}

# IF run a shell then run a shell. if load the shell then not running shell. just load
if [ "$(basename $0)" == "mac.k" ]; then
    declare -F _k_k >& /dev/null || source $_K_BIN/k.k
    _k_load_include $0

    # Run this script to main function
    _k_$(basename $0 | sed "s/${KTAG}$//g") "$@" || exit $?
fi
