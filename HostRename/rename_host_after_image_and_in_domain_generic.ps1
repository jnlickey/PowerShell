###############################################################
# This script renames a computer based off of it's IP Address
# which is associated to it's location.
#
# Created by: nlickey
###############################################################

function IP_ADDR_REGEX($string){
	$regex_IP = '\d{1,}\.\d{1,}\.(\d{1,})\.(\d{1,})'
	$string -match $regex_IP_string
}
function BUILD_NEW_HOSTNAME_PREFIX($roomNum){
	$cseRooms = "<RoomNum>" -or "<RoomNum>" -or "<RoomNum>" -or "<RoomNum>" -or "<RoomNum>"
	$phyRooms = "<RoomNum>" -or "<RoomNum>" -or "<RoomNum>" -or "<RoomNum>" -or "<RoomNum>"
	if($cseRooms -contains $roomNum){
		"Default_hostname_prefix"
	}elseif($phyRooms -contains $roomNum){
		"Secondary_hostname_prefix"
	}
}
function BUILD_NEW_HOSTNAME_THIRDOCT($machNum){
	if($machNum.length -lt 2){
		$machNum = "00" + $machNum
	}elseif($machNum.length -lt 3){
		$machNum = "0" + $machNum
	}
	$machNum
}
function BUILD_NEW_HOSTNAME_FOURTHOCT($machNum){
	if($machNum.length -lt 2){
		$machNum = "0" + $machNum
	}
	$machNum
}
function RESOLVE_IP_OCTETS($string){
    $ipv4_string = $string -match 'IPv4 .*\d{1,}\.\d{1,}\.(\d{1,})\.(\d{1,})'
    $ip = $ipv4_string[0].split(": ")
    $ip_oct = $ip[17].split(".")
    $ip_oct
}

#$current_hostname=hostname  NOTE: $env:computername can replace this command in Add-Computer line below
$ip_info_string=ipconfig
$ip_info_string = IP_ADDR_REGEX $ip_info_string

$ip = RESOLVE_IP_OCTETS $ip_info_string
$new_hostname = BUILD_NEW_HOSTNAME_PREFIX $ip[2] 
$new_hostname += BUILD_NEW_HOSTNAME_THIRDOCT $ip[2]
$new_hostname += BUILD_NEW_HOSTNAME_FOURTHOCT($ip[3])

$username      = 'domain\<UserWithPermission>'
$password      = '<Password>'
$domain        = "<DomainName>"
$server		   = "<ServerName.DomainName>"

$secstring = ConvertTo-SecureString $password -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($username, $secstring)
if ($env:computername -ne $new_hostname)
{
    Add-Computer -DomainName $domain -Credential $credential -ComputerName $env:computername -NewName $new_hostname -Server $server -Restart -Verbose -Force
}
elseif($env:computername -eq $new_hostname)
{
    remove-computer -DomainName $domain -Credential $credential -passthru -verbose
    Add-Computer -DomainName $domain -Credential $credential -ComputerName $env:computername -Server $server -Restart -Verbose -Force
}
else
{
    write-host ("The computername $env:computername, DOES NOT need to be changed!")
}
