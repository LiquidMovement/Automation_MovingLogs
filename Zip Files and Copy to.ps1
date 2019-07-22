$sourceFolder = '\\<NETWORK PATH>\Catalogs\XXXX'
$destinationFolder = '\\name@YOURDOMAIN\c$\temp\PScopy'
$workingdir = 'C:\Catalogs-to-DR\temp'
$now = Get-Date
$backdays = 2
$daysago = $now.AddDays(-$backdays)
$limit = (Get-Date).AddDays(-3)
$today = (get-date -UFormat %m%d%y)

Function createzip
{
    If ($_.CreationTime.Date -lt $now.date -and $_.CreationTime.Date -gt $daysago.date) 
    {
    Compress-Archive -Path $sourceFolder\$_* -CompressionLevel optimal -DestinationPath $workingdir\$today.zip 
    }
}

Function updatezip
{
    If ($_.CreationTime.Date -lt $now.date -and $_.CreationTime.Date -gt $daysago.date)
    {    
    Compress-Archive -Path $sourceFolder\$_* -CompressionLevel optimal -DestinationPath $workingdir\$today.zip -update
    }
}

Get-ChildItem $sourceFolder -Recurse | Where-Object { $_ -is [System.IO.FileInfo] } | ForEach-Object {
	If (test-path $workingdir\$today.zip){
        $_ | updatezip
    }else{
        $_ | createzip
    }
}

If (test-path $workingdir\$today.zip){
        Copy-Item $workingdir\$today.zip $destinationfolder\$today.zip
        # Delete files older than the $limit.
        Get-ChildItem -Path $destinationfolder -Recurse -Force | Where-Object { !$_.PSIsContainer -and $_.lastwritetime -lt $limit } | Remove-Item -Force
        }else{
        #send email on failure
    Send-MailMessage -to name@YOURDOMAIN.com -From name@YOURDOMAIN.com -subject 'Catalog zip and transfer failed - HRXMGMT' -body 'The copy from XXXX to XXXX has Failed.  This indicates the Zip Process has failed.  Check XXXX for further details.' -smtp smtp.YOURDOMAIN.com
}