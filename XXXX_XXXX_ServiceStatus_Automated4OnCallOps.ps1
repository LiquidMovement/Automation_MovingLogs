$Date = (Get-Date)
$status = get-service -ComputerName XXXX -name XXXX,XXXX | ft -AutoSize
$pSync = Get-Service -ComputerName XXXX -Name XXXX | Select-Object Status
$sSync = Get-Service -ComputerName XXXX -Name XXXX | Select-Object Status

#$Date+$status | out-file "C:\Scripts\temp\XXXX.txt" -Append
$Port = $pSync.Status
$Secure = $sSync.Status

if(($pSync.Status -ne "Running") -or ($sSync.Status -ne "Running")){
    Send-MailMessage -to name@YOURDOMAIN.com -From name@YOURDOMAIN.com -subject 'ERROR - XXXX Status - XXXX' -body "XXXX or XXXX is not running. Investigate. `nXXXX : $Port // XXXX : $Secure" -smtp smtp.YOURDOMAIN.com
}
else{
    Send-MailMessage -to name@YOURDOMAIN.com -From name@YOURDOMAIN.com -subject 'XXXX Status - XXXX' -body "XXXX : $Port // XXXX : $Secure" -smtp smtp.YOURDOMAIN.com 
}