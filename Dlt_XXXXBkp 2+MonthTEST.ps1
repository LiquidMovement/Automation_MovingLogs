$source = "C:\temp\New Folder"
$limit = (Get-Date).AddDays(-61)

try{
    if(-not(test-path $source))
    {
        Throw "Uh-oh there seems to be an error w/ the current path : $source"
    }
   
    Write-host "Party time!"
     Write-host "Are sure you'd like to erase files in $source that are older than $limit ?"
    $userInput = Read-host -Prompt "Enter Y to continue OR Enter N to terminate/cancel"
    
    if($userInput -eq "Y")
    {
        Get-ChildItem -Path $source -Recurse -Force | Where-Object { !$_.PSIsContainer -and $_.lastwritetime -lt $limit } | Remove-Item -Force
        Write-host "Complete"
        Pause
    }
     else
    {
        Write-host "You entered : $userInput. Your PS Session will be terminated now & nothing will be deleted."
        Pause
        Exit-PSSession
    }
    
}
catch{
       $_
       Pause
}