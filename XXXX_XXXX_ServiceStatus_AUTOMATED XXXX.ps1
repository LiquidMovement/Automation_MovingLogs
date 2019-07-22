$status = get-service -ComputerName XXXX -name XXXX,XXXX | ft -AutoSize
$pSync = Get-Service -ComputerName XXXX -Name XXXX | Select-Object Status
$sSync = Get-Service -ComputerName XXXX -Name XXXX | Select-Object Status

if(($pSync.Status -ne "Running") -or ($sSync.Status -ne "Running")){
    Send-MailMessage -to name@YOURDOMAIN.com -From name@YOURDOMAIN.com -subject 'ERROR - XXXX/XXXX Status - XXXX' -body "XXXX or XXXX is not running. Investigate.`n$status" -smtp smtp.YOURDOMAIN.com
}
else{
    Send-MailMessage -to name@YOURDOMAIN.com -From name@YOURDOMAIN.com -subject 'XXXX/XXXX Status - XXXX' -body "$status" -smtp smtp.YOURDOMAIN.com
}