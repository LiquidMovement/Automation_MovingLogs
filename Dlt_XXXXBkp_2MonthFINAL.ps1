$source = "\\<NETWORK PATH>\ITBackups\XXXX-backups"
$limit = (Get-Date).AddDays(-61)

try{
    if(-not(test-path $source))
    {
        Send-MailMessage -to name@YOURDOMAIN.com -From name@YOURDOMAIN.com -subject 'XXXX Backup Log Delete Failed - XXXX' -body 'The delete from \\<NETWORK PATH>\ITBackups\XXXX-backups has Failed.  This indicates there was an issue with the "Path".  Check XXXX for further details.' -smtp smtp.YOURDOMAIN.com
    }
     else
    {
        Get-ChildItem -Path $source -Recurse -Force | Where-Object { !$_.PSIsContainer -and $_.lastwritetime -lt $limit } | Remove-Item -Force
        Send-MailMessage -to name@YOURDOMAIN.com -From name@YOURDOMAIN.com -subject 'XXXX Backup Log Delete Success - XXXX' -body 'The delete from \\<NETWORK PATH>\ITBackups\XXXX-backups has completed!' -smtp smtp.YOURDOMAIN.com
    }
    
}
catch{
       $_
           
}