function create_User_DB_List {
#########################################################################
# This function creates a list of users that need DB's and accounts setup
# on a server. It then saves the CSV file to a shared drive on the DB
# Server
# SERVERNAME: DRIVE_LETTER:\path\to\directory\Check_for_New_DB_Accts_Dir
#
# There is another powershell script that monitors for files dropped on
# the DB Server. It is ran via TaskScheduler on Windows. When that script
# sees a CSV file located in the directory noted above, it then executes
# some other Perl scripts that actually create the DB's and SQL login's. 
#
# Created by: nlickey 11/11/2015
##########################################################################
    param([string]$path)
	$headers = '"CRN","SUBJ,CODE","CRS,NUM","ID","LAST,NAME","FIRST,NAME","1ST,MJR","EMAIL"'
	$input_path = 'X:\Desktop\CSS_SHORT_CLASS--TEST.CSV'
    #$input_path = $path
    $export_path = 'S:\path\to\directory\Check_for_New_DB_Accts_Dir\Database_Accounts.csv'
	#$file = 'Database_Accounts.csv'
	
    $csv = import-csv -Path $path
    foreach($line in $csv){
        if(($line."SUBJ,CODE" -eq 'COURSE_LETTERS') -and ($line."CRS,NUM" -eq 'COURSE_NUMBER')){
            #Write-output ($line."SUBJ,CODE" +" "+  $line."CRS,NUM" + " " + $line."EMAIL"+"@example.com") | Get-Unique
            if ($line."LAST,NAME".contains("'")){
                $line."LAST,NAME" = $line."LAST,NAME".replace("'",'')
                #write-host ($line."LAST,NAME")
            }
            if ($line."LAST,NAME".length -gt 7){
                $LName = $line."LAST,NAME".substring(0,7).ToLower()
                $FName = $line."FIRST,NAME".substring(0,1).ToLower()
                $EMAIL = $line."EMAIL".ToLower()
                Write-Output ('"'+$EMAIL+'@example.com"' + ', "' + $FName+$LName+'"') | Out-File $export_path -Append
            }
            else{
                $LName = $line."LAST,NAME".ToLower()
                $FName = $line."FIRST,NAME".substring(0,1).ToLower()
                $EMAIL = $line."EMAIL".ToLower()
                Write-Output ('"'+$EMAIL+'@example.com"' + ', "' + $FName+$LName+'"') | Out-File $export_path -Append
            } #End Else
        } # End IF
    } # End FOREACH
} # End Function DB_List

create_User_DB_List
