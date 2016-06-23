name = newuserAcctName
users = newuserAcctGroup
Invoke-Expression -Command "& 'C:\Program Files (x86)\PuTTY\plink.exe' username@servername /path/to/script/mkhomedirlinux.sh $name $users"