


# SSHFS
sshfs_mount(){
  host=$1
  path=$1
  user=$(whoami)
  if [[ -z  ]]; then
    mount_loc=$HOME
  else
    mount_loc=$MYWSROOT
  fi
  sshfs $user@$host:$path $mount_lc
  exc=$?
  if [[ -z exc ]]; then
    echo "Mounted at $mount_lc"
  else
    echo "Error in Mounting!"
  fi
}

sshfs_unmount(){
   fusermount -u  $1
}
