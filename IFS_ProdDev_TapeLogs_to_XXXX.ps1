
$ifs1 = "\\XXXX\pdf\BkpLogs"
$ifs13 = "\\XXXX\pdf\BkpLogs"
$HRXDev = "\\XXXX\D$\_BACKUP_LOGS\DEV"
$HRXProd = "\\XXXX\D$\_BACKUP_LOGS\PROD"

#*** GRAB ALL FILES WITHIN BkpLogs Folders on .1 & .13 ***#
$files1 = Get-ChildItem "$ifs1\*.*"
$files13 = Get-ChildItem "$ifs13\*.*"

#*** DATE VARIABLES -- USED TO TEST & PLACE THE FILES IN THE CORRECT FOLDERS ***#
#*** ALSO USED TO CREATE DIRECTORYS IF THE FOLDERS DO NOT EXIST ***#

$DateM = (Get-Date)
$MonPrev = (Get-Date).AddMonths(-1).ToString('MMM')
$MonNumPrev = (Get-Date).AddMonths(-1).Month
$MonCurr = Get-Date -format MMM
$MonNumCurr = $DateM.Month
$Date1 = $DateM.Day
$DateYear = $DateM.Year
$DatePrevYear = (Get-Date).AddYears(-1).Year

#***
function Move-Prod{
    $prodMsg = $false      #*** Variable to test success or failure for email notification

    if(test-path $HRXProdYear\$folderProd){
        Move-Item $files1 "$HRXProdYear\$folderProd"
        $prodMsg = $true
    }
    else{
	    new-item "$HRXProdYear\$folderProd" -type Directory
	    if(Test-Path "$HRXProdYear\$folderProd"){
		    Move-Item $files1 "$HRXProdYear\$folderProd"
		    $prodMsg = $true
	    }
	    else{
		    $prodMsg = $false
	    }
    }

    if($prodMsg -eq $true){
        Write-Host "Transfer of `n$files1 `nto `n$HRXProdYear\$folderProd `nsuccessfully completed.`n"

    }
    else{
        Write-Host "Transfer of `n$files1 `nto `n$HRXProdYear\$folderProd failed. `nPlease investigate.`n"
    }
}

#***
function Move-Dev{
    $devMsg = $false      #*** Variable to test success or failure for email notification

    if(test-path $HRXDevYear\$folderDev){
        Move-Item $files13 "$HRXDevYear\$folderDev"
        $devMsg = $true
    }
    else{
        new-item "$HRXDevYear\$folderDev" -type Directory
        if(Test-Path "$HRXDevYear\$folderDev"){
            Move-Item $files13 "$HRXDevYear\$folderDev"
            $devMsg = $true
        }
        else{
            $devMsg = $false
        }
    }

    if($devMsg -eq $true){
        Write-Host "Transfer of `n$files13 `nto `n$HRXDevYear\$folderDev `nsuccessfully completed.`n"
    }
    else{
        Write-Host "Transfer of $files13 to $HRXDevYear\$folderDev failed. `nPlease investigate.`n"
    }
}

#*** IF IT IS JAN 1st THIS SHOULD PLACE DEC 31st FILES BACK IN PREVIOUS YEAR ***#
if($MonCurr -eq "JAN" -and $Date1 -eq "1"){

    $HRXDevYear = "$HRXDev\$DatePrevYear"      #*** Set HRXDEV year to Previous Year
    $folderDev = "$MonNumPrev-$MonPrev"        #*** Set HRXDEV Month Folder to Previous Month

    #*** Test Path HRXDevYear
    if(test-path $HRXDevYear){
        Move-Dev
    }
    #*** Unsuccessful test creates HRXDev\DatePrevYear
    else{
        New-Item "$HRXDev\$DatePrevYear" -type Directory       
        Move-Dev
    }

    $HRXProdYear = "$HRXProd\$DatePrevYear\"   #*** Set HRXProd year to Previous Year
    $folderProd = "$MonNumPrev-$MonPrev"
    
    #*** Test Path HRXProdYear
    if(test-path $HRXProdYear){
        Move-Prod
    }
    #*** Unsuccessful test creates HRXProd\DatePrevYear
    else{
        New-Item "$HRXProd\$DatePrevYear" -type Directory
        Move-Prod
    }

}

#*** ELSEIF IT IS THE 1st of ANY OTHER MONTH (NOT JAN) THIS SHOULD PLACE THE FILES IN THE CURRENT YEAR AND PREVIOUS MONTH ***#
elseif($Date1 -eq "1"){

    $HRXDevYear = "$HRXDev\$DateYear"         #*** Set HRXDEV year to Current Year
    $folderDev = "$MonNumPrev-$MonPrev"       #*** Set HRXDEV Month Folder to Previous Month

    #*** Test Path HRXDevYear
    if(test-path $HRXDevYear){
        Move-Dev
    }
    #*** Unsuccessful test creates HRXDev\DateYear
    else{
        New-Item "$HRXDev\$DateYear" -type Directory
        Move-Dev
    }

    $HRXProdYear = "$HRXProd\$DateYear\"      #*** Set HRXProd year to Current Year
    $folderProd = "$MonNumPrev-$MonPrev"      #*** Set HRXProd Month Folder to Previous Month
    
    #*** Test Path HRXProdYear
    if(test-path $HRXProdYear){
        Move-Prod
    }
    #*** Unsuccessful test creates HRXProd\DateYear
    else{
        New-Item "$HRXProd\$DateYear" -type Directory
        Move-Prod
    }

}

#*** ELSE IF IT IS ANY OTHER DATE THIS SHOULD PLACE THE FILES IN THE CURRENT YEAR AND MONTH ***#
else{

    $HRXDevYear = "$HRXDev\$DateYear"       #*** Set HRXDEV year to Current Year
    $folderDev = "$MonNumCurr-$MonCurr"     #*** Set HRXDEV Month Folder to Current Month

    #*** Test Path HRXDevYear
    if(test-path $HRXDevYear){
        Move-Dev
    }
    #*** Unsuccessful test creates HRXDev\DateYear
    else{
        New-Item "$HRXDev\$DateYear" -type Directory
        Move-Dev
    }

    $HRXProdYear = "$HRXProd\$DateYear\"    #*** Set HRXProd year to Current Year
    $folderProd = "$MonNumCurr-$MonCurr"
 
    #*** Test Path HRXProdYear
    if(test-path $HRXProdYear){
        Move-Prod
    }
    #*** Unsuccessful test creates HRXProd\DateYear
    else{
        New-Item "$HRXProd\$DateYear" -type Directory
        Move-Prod
    }
}

Pause
