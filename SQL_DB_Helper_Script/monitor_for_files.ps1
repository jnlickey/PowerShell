####################################################################################
# Created by: nlickey
# 11/09/2015
#
# Used in conjunction with the new AD Powershell account creation scripts in
# order to create SQL DB's and logins.
#
# This script relies on the Account creation script on Server1 or Server2 to create
# a list of users in the form of email address and username with quotes:
#
# "Cheese_Pizza@example.com","cpizza"
#
# Then this script will generate a new folder if one does not already exist with
# the current date to keep track of when DB Accounts are created. This script will
# then call the perl scripts for creating the databases and SQL user accounts.
#
# Finally this script moves the account creation file from the folder located at 
# F:\sysmgt\Check_for_New_DB_Accts_Dir to F:\sysmgt\<current_date_folder>
#
####################################################################################

$path_to_check = "F:\sysmgt\Check_for_New_DB_Accts_Dir\*"

#Creates new destination folder if it doesn't exist
function createFolder {

    if (!(Test-Path -path "F:\sysmgt\$((Get-Date).ToString("yyyyMMdd"))")) {
        write-host ("Creating new folder...")
        $folder = New-Item -ItemType Directory -Path "F:\sysmgt\$((Get-Date).ToString("yyyyMMdd"))"
        write-host ("Folder is: " + $folder)
        $folder
    } # if (!(Test-Path -path D:Data))
} # End Function createFolder

# Checks to see if CSV file exists, if so it creates new SQL DB Accounts
function check {

    foreach ($f in Get-ChildItem $path_to_check){
	    foreach ($i in Get-ChildItem $f)
	    {
		    if ($i.extension -eq ".csv")
		    {
                write-host($i.name + " File Exists")
                write-host ("Processing... " + $i)
                start-process "C:\Perl64\bin\perl.exe " "F:\sysmgt\scripts\sql-02-createusers.pl --file $i" -NoNewWindow -Wait
                [string]$file = $i   
            }
		    else
		    {
                write-host ("***CSV File MISSING***")
		    } # End IF ELSE
    	} # End $i ForEach
    } # End $f ForEach

    $folder = createFolder
    $files = $file.Split("\")
    
    Move-Item $file $folder
    write-host("Moving file: " + $file + " to " + $folder + "\" + $files[4])
} # End Function check

check
