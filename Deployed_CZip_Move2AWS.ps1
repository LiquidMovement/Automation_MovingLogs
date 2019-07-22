

#***** VARIABLES *****
$Date = (Get-Date).ToShortDateString()
$yestDate = (Get-Date).AddDays(-1).ToShortDateString()
$Date2 = (Get-Date).AddDays(-2).ToShortDateString()
$Date3 = (Get-Date).AddDays(-3).ToShortDateString()
$Date4 = (Get-Date).AddDays(-4).ToShortDateString()

$Back1 = (Get-Date).AddDays(-1).ToString('MMddyy')
$Back2 = (Get-Date).AddDays(-2).ToString('MMddyy')
$Back3 = (Get-Date).AddDays(-3).ToString('MMddyy')
$Back4 = (Get-Date).AddDays(-4).ToString('MMddyy')


$Source = '\\XXXX\E$\Catalogs\XXXX'
$Jail = '\\XXXX\E$\Catalogs\Catalogs-to-DR\HoldingCell'
$Dest = '\\XXXX\F$\DRCatalogs'
$HoldingCell = '\\XXXX\E$\Catalogs\Catalogs-to-DR\HoldingCell'

$folder1 = "$Jail\$Back1"
$folder2 = "$Jail\$Back2"
$folder3 = "$Jail\$Back3"
$folder4 = "$Jail\$Back4"
#***** END VARIABLES *****



#****** FUNCTIONS ********
function czip1back{
    Get-ChildItem $Source | Where-Object{$_.CreationTime -gt $yestDate -and $_.CreationTime -lt $Date} | ForEach-Object{Copy-Item $_.Fullname $folder1}
    Compress-Archive -Path $folder1 -CompressionLevel Optimal -DestinationPath "$HoldingCell\$Back1.zip"

    if(Test-Path "$HoldingCell\$Back1.zip"){
        Move-Item -Path "$HoldingCell\$Back1.zip" -Destination $Dest -Force
        Remove-Item -Path $folder1 -Recurse
    }
    else{Write-Host "Crap"}
}


function czip2back{
    Get-ChildItem $Source | Where-Object{$_.CreationTime -gt $Date2 -and $_.CreationTime -lt $yestDate} | ForEach-Object{Copy-Item $_.Fullname $folder2}
    Compress-Archive -Path $folder2 -CompressionLevel Optimal -DestinationPath "$HoldingCell\$Back2.zip"

    if(Test-Path "$HoldingCell\$Back2.zip"){
        Move-Item -Path "$HoldingCell\$Back2.zip" -Destination $Dest -Force
        Remove-Item -Path $folder2 -Recurse
    }
    else{Write-Host "Crap"}
}


function czip3back{
    Get-ChildItem $Source | Where-Object{$_.CreationTime -gt $Date3 -and $_.CreationTime -lt $Date2} | ForEach-Object{Copy-Item $_.Fullname $folder3}
    Compress-Archive -Path $folder3 -CompressionLevel Optimal -DestinationPath "$HoldingCell\$Back3.zip"

    if(Test-Path "$HoldingCell\$Back3.zip"){
        Move-Item -Path "$HoldingCell\$Back3.zip" -Destination $Dest -Force
        Remove-Item -Path $folder3 -Recurse    
    }
    else{Write-Host "Crap"}
}


function czip4back{
    Get-ChildItem $Source | Where-Object{$_.CreationTime -gt $Date4 -and $_.CreationTime -lt $Date3} | ForEach-Object{Copy-Item $_.Fullname $folder4}
    Compress-Archive -Path $folder4 -CompressionLevel Optimal -DestinationPath "$HoldingCell\$Back4.zip"

    if(Test-Path "$HoldingCell\$Back4.zip"){
        Move-Item -Path "$HoldingCell\$Back4.zip" -Destination $Dest -Force
        Remove-Item -Path $folder4 -Recurse
    }
    else{Write-Host "Crap"}
}
#******* END FUNCTIONS *********



#**************************************************************************
#************************ MAIN BODY OF SCRIPT *****************************
#**************************************************************************
if(test-path "$folder1"){
    czip2back
}
else{
    New-Item $folder1 -type Directory
    if(Test-Path $folder1){
        czip1back
    }
}

if(test-path "$folder2"){
    czip2back
}
else{
    New-Item $folder2 -type Directory
    if(Test-Path $folder2){
        czip2back
    }
}

if(test-path "$folder3"){
    czip3back
}
else{
    New-Item $folder3 -type Directory
    if(Test-Path $folder3){
        czip3back
    }
}


if(test-path "$folder4"){
    czip4back
}
else{
    New-Item $folder4 -type Directory
    if(Test-Path $folder4){
        czip4back
    }
}


#*** TEST-PATH // SEND EMAIL ON FALSE ***


if((Test-Path "$Dest\$Back1.zip") -and (Test-Path "$Dest\$Back2.zip") -and (Test-Path "$Dest\$Back3.zip") -and (Test-Path "$Dest\$Back4.zip")){
    
}
else{
    Send-MailMessage -to name@YOURDOMAIN.com -From name@YOURDOMAIN.com -subject 'Catalog zip and transfer failed - XXXX' -body 'Some where in the process to copy & zip Catalogs on XXXX, followed up by a transfer of the zipped files to XXXX -- something has failed to complete. Check \\XXXX\E$\Catalogs\Catalogs-to-DR\HoldingCell\ for the creation date folder(s) and the zipped folder(s) for each creation date folder. Any creation date folders that are not zipped will need to be zipped and moved to \\XXXX\f$\DRCatalogs\. Any zipped folders that remain in this folder, will need to be moved to \\XXXX\f$\DRCatalogs\ as well. Once corrected, make sure to delete any remaining folders in the HoldingCell folder on XXXX. For further details, the script for this process can be found at \\XXXX\e$\Catalogs\Catalogs-to-DR\.' -smtp smtp.YOURDOMAIN.com
}

#**** END SCRIPT BODY *****