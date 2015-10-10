# Created by nlickey 10/07/2015
#
# This script was created to disable access to users shared space and linux access until the user has signed
# the CSE Department's Acceptable Computer Use Policy & Agreement located at https://moodle.cse.taylor.edu
# 
# Before running this script you will need to do a couple of things:
# 1) Login to Moodle, goto the Acceptable Computer Use Policy & Agreement
# course, and download/Export the grades from the course. To do this, on the left hand column under Administration,
# click on Grades | Export | Plain text file | Export format Options (Choose Excluded suspended users,
# Grade decimal points = 0, Seperator= comma) | Download
# Adwin1=> C:\Users\Administrator.CS\Desktop\Moodle_Acceptable_Use_Agreement_Scripts\Agreements_1 Grades-comma_separated.csv
#
# 2) Add users that you want to exclude from this script, by adding their information to the exclude list, located below:
# Adwin1 => C:\\Users\\Administrator.CS\\Desktop\\Moodle_Acceptable_Use_Agreement_Scripts\\Moodle_excluded_list.csv

Import-Module ActiveDirectory

#Set-ExecutionPolicy RemoteSigned
Set-ExecutionPolicy Unrestricted

$path_to_Moodle_list = "X:\\Desktop\\Moodle_Acceptable_Use_Agreement_Scripts\\Agreements_1 Grades-comma_separated.csv"
$path_to_excluded_list = "X:\\Desktop\\Moodle_Acceptable_Use_Agreement_Scripts\\Moodle_excluded_list.csv" 
#################$path_to_pMoodle_Not_Signed_Agreement = "X:\\Desktop\\Moodle_Acceptable_Use_Agreement_Scripts\\pMoodle_Not_Signed_Agreement.CSV"
#################$path_to_pMoodle_Signed_Agreement = "X:\\Desktop\\Moodle_Acceptable_Use_Agreement_Scripts\\pMoodle_Signed_Agreement.CSV"
$path_to_pMoodle_Minus_Excluded = "X:\\Desktop\\Moodle_Acceptable_Use_Agreement_Scripts\\pMoodle_Minus_Excluded.CSV"

# Create Array's
$UserNotSigned_Output = @()
$UserSignedOutput = @()

#Import CSV files
$MoodleListAll = import-csv -path $path_to_Moodle_list | where-object {$_."Course total (Real)" -eq "-" -or "100"} |select "Email Address", "Course total (Real)"
##################$Moodle_list_NotSigned = import-csv -path $path_to_Moodle_list | where-object {$_."Course total (Real)" -eq "-"} | select "Email Address", "Course total (Real)"
$excluded_list = import-csv -path $path_to_excluded_list

# Regretfully took from http://powershell.org/wp/forums/topic/compare-two-csv-files-and-remove-the-same-values/ to check for duplicates
$duplcates = Compare-Object $MoodleListAll $excluded_list -Property "Email Address" -IncludeEqual -ExcludeDifferent -PassThru | Select-Object -ExpandProperty "Email Address"
$MoodleListAll | Where-Object {$_."Email Address" -notin $duplcates} | Export-CSV -Path $path_to_pMoodle_Minus_Excluded -noTypeInformation 
###################$duplcates_NotSigned = Compare-Object $Moodle_list_NotSigned $excluded_list -Property "Email Address" -IncludeEqual -ExcludeDifferent -PassThru | Select-Object -ExpandProperty "Email Address"
###################$Moodle_list_NotSigned | Where-Object {$_."Email Address" -notin $duplcates_NotSigned -and $_."Course total (Real)" -eq "-"} | Export-CSV -Path $path_to_pMoodle_Not_Signed_Agreement -noTypeInformation 

$MoodleMinusExcluded = import-csv -path $path_to_pMoodle_Minus_Excluded

# If the Agreement has been signed, this function is executed
function AgreementSigned{
    $email_Signed = $Signed | foreach {$_."Email address"}
    $Signed_user_info_before = $email_Signed | foreach-object {Get-ADUser -Filter {EmailAddress -eq $_} -Properties Mail, loginShell, name | Select Mail, loginShell, name}
    $Signed_user_info_before | foreach-object {Set-ADUser -Identity $_.name -replace @{loginShell="/bin/bash"}}
    $Signed_user_info_after = $email_Signed | foreach-object {Get-ADUser -Filter {EmailAddress -eq $_} -Properties Mail, loginShell, name | Select Mail, loginShell, name}
    return $Signed_user_info_after
}

# If the Agreement has not been signed, this function is executed
function AgreementNotSigned{
    $email_NotSigned = $NotSigned | foreach {$_."Email address"}
    $NotSigned_user_info_before = $email_NotSigned | foreach-object {Get-ADUser -Filter {EmailAddress -eq $_} -Properties Mail, loginShell, name | Select Mail, loginShell, name}
    $NotSigned_user_info_before | foreach-object {Set-ADUser -Identity $_.name -replace @{loginShell="/bin/false"}}
    $NotSigned_user_info_after = $email_NotSigned | foreach-object {Get-ADUser -Filter {EmailAddress -eq $_} -Properties Mail, loginShell, name | Select Mail, loginShell, name}
    return $NotSigned_user_info_after
}

# Grade determines which function is called
if ($MoodleMinusExcluded."Course total (Real)" -eq "100")
{
    #AgreementSigned
    $Signed = $MoodleMinusExcluded | where-object {$_."Course total (Real)" -eq "100"} | select "Email Address", "Course total (Real)"
    AgreementSigned($Signed)
}
if ($MoodleMinusExcluded."Course total (Real)" -eq "-")
{
    #AgreementNotSigned
    $NotSigned = $MoodleMinusExcluded | where-object {$_."Course total (Real)" -eq "-"} | select "Email Address", "Course total (Real)"
    AgreementNotSigned($NotSigned)
}


# Not Signed Agreement
#$UserNotSigned_Output += import-csv -path $path_to_pMoodle_Not_Signed_Agreement
#$email = $UserNotSigned_Output | foreach {$_."Email address"}
#$user_info_before = $email | foreach-object {Get-ADUser -Filter {EmailAddress -eq $_} -Properties Mail, loginShell, name | Select Mail, loginShell, name}
#$user_info_before | foreach-object {Set-ADUser -Identity $_.name -replace @{loginShell="/bin/false"}}
#$user_info_after = $email | foreach-object {Get-ADUser -Filter {EmailAddress -eq $_} -Properties Mail, loginShell, name | Select Mail, loginShell, name}

#"BEFORE`n"+ 
#$user_info_before
#$Signed_user_info_before + "`n"+
#$NotSigned_user_info_before + "`n"

#"`nAFTER"
#$user_info_after
#$Signed_user_info_after
#$NotSigned_user_info_after
