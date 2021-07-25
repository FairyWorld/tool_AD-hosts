work_dir=/sdcard/Android/ADhosts
script_dir=${0%/*}

. $work_dir/Cron.ini

[ -f /data/adb/magisk/busybox ] && alias crond="/data/adb/magisk/busybox crond"

if [ $regular_update = "on" ]; then
   pid_text=$(ps -elf | grep "$script_dir/crontabs" | awk -F ' ' '{print $2}')
   for pid in ${pid_text[*]}; do
      kill -9 $pid &> /dev/null
   done
   rm -rf $script_dir/crontabs/root
   touch $script_dir/crontabs/root
   if [[ $time_format = "24" || $time_format = "AM" ]]; then
      H="$(echo $time | awk -F ':' '{print $1}')"
      M="$(echo $time | awk -F ':' '{print $2}')"
      if [ $M = "00" ]; then
         export M="0"
      elif $(echo "$M" | grep -q '^0'); then
         export M="$(echo $time | awk -F ':' '{print $2}' | awk -F '0' '{print $2}')"
      fi
   elif [ $time_format = "PM" ]; then
      H="$(($(echo $time | awk -F ':' '{print $1}') + 12))"
      M="$(echo $time | awk -F ':' '{print $2}')
      if $(echo "$H" | grep -q '^0'); then
         export H="$(echo $time | awk -F ':' '{print $1}' | awk -F '0' '{print $2}')"
      fi
      if [ $M = "00" ]; then
         export M="0"
      elif $(echo "$M" | grep -q '^0'); then
         export M="$(echo $time | awk -F ':' '{print $2}' | awk -F '0' '{print $2}')"
      fi
   fi
   if [ $wupdate = "y" ]; then
      DOW="$wday"
   elif [ $wupdate = "n" ]; then
      DOW="*"
   else
      echo "错误参数:$wupdate"
      echo "请输入 y/n"
      exit 1
   fi
   if [ $mupdate = "y" ]; then
      DOM="$wdate"
   elif [ $mupdate = "n" ]; then
      DOM="*"
   else
      echo "错误参数:$mupdate"
      echo "请输入 y/n"
      exit 1
   fi
   echo "$M $H $DOM * $DOW  sh $script_dir/functions.sh" >> $script_dir/crontabs/root
   chmod 777 $script_dir/crontabs/root
   crond -b -c $script_dir/crontabs
   echo "已开启定时更新服务"
elif [ $regular_update = "off" ]; then
   pid_text=$(ps -elf | grep "$script_dir/crontabs" | awk -F ' ' '{print $2}')
   for pid in ${pid_text[*]}; do
      kill -9 $pid &> /dev/null
   done
   echo "已关闭定时更新服务"
else
   echo "错误参数:$regular_update"
   echo "请输入 on/off"
   exit 1
fi