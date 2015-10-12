# nlickey 20151012
#
# Code Signing Script

$filepath = Read-Host -Prompt 'Enter complete path to file needing to be signed: '
$cert=(dir cert:currentuser\my\ -CodeSigningCert)
Set-AuthenticodeSignature $filepath $cert -TimestampServer http://timestamp.comodoca.com/authenticode
