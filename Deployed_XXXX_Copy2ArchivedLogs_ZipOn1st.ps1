#**************************************************************************************************************************
#*Carter Cornelius // 01/04/18
#*
#*Copy Network Backup Logs from XXXX to XXXX
#*Script once scheduled will run daily // it copies the previous 3 days worth of logs to the coordinating folder on XXXX
#*It's pulling past 3 days to ensure all logs are copies from XXXX to XXXX as some Backups can take several days
#*
#*
#*** UPDATE *** 
#*Carter Cornelius // 11/09/18
#*Added if, elseif, elseif statement to account for Current Year vs. Previous Year
#*Changed $destPart to account for the base path on XXXX, removed 2018 from the path
#*Created two new variables $destCurrYear & $destPrevYear to account for the change in year
#*In theory this should be able to run this script daily, yearly without any intervention required unless the paths for the bkplogs & XXXX change
#*
#*
#*** UPDATE ***
#*Carter Cornelius // 01/10/19
#*Added 2nd set of variables for previous, previous Month (towards bottom of the script)
#*Added 2nd if, elseif, elseif, else to zip previous, previous Month's folder (towards bottom of the script)
#*Process will zip, test-path for new zip, if true will remove the folder that was zipped. If false, will alert admins of failed test-path
#**************************************************************************************************************************


#**********************************************************************
#***************************VARIABLES**********************************
#**********************************************************************

$Today = Get-Date -format d
$Yesterday = (Get-date).AddDays(-1)
$YestFolder = $Yesterday.day
$2Days = (Get-Date).AddDays(-2)
$2DaysFolder = $2Days.Day
$3Days = (Get-Date).AddDays(-3)
$3DaysFolder = $3Days.Day

    #*********Variables below used to construct $NewFolder // $NewFolder creates the SubFolder such as 1 - Jan or 2 - Feb
$DateV = (Get-Date)
$MonthTxtPrev = (Get-Date).AddMonths(-1).ToString('MMM')
$MonthNumPrev = (Get-Date).AddMonths(-1).Month
$MonthTxtCurr = Get-Date -format MMM
$MonthNumCurr = $DateV.Month

$Year = $DateV.Year
$PrevYear = (Get-Date).AddYears(-1).Year

    #***********$DateRevi1 used to test the day // $2Date, $3Date & $4Date used as variable in pulling correct Date Created
$Date = (Get-Date)
$DateR2 = $Date.toString()
$DateRevi1 = $Date.day
$2Date = (Get-Date).AddDays(-1).ToShortDateString()
$3Date = (Get-Date).AddDays(-2).ToShortDateString()
$4Date = (Get-Date).AddDays(-3).ToShortDateString()

    #*** SOURCE VARIABLES & YEAR VARIABLES ***#
$source = "\\XXXX\E$\JobLogs" 
$destPart = "\\XXXX\E$\ArchivedLogs" #*** Base path -- see below for paths to account for the Year(s)
$destCurrYear = "$destPart\$Year"                #*** Path on XXXX for Current Year
$destPrevYear = "$destPart\$PrevYear"            #*** Path on XXXX for Previous Year (if it's Jan 1st, 2nd or 3rd)



    #*** If Statement to Test-Path to \\XXXX\D$\_BACKUP_LOGS\NETWORK\<Current Year>&<Previous Year>
    #*** If either of the folders do not exist, statement creates the directory

if($MonthTxtCurr -eq "JAN" -and $DateRevi1 -eq "1"){
    if(Test-Path $destPrevYear){
        #do nothing
    }
    else{
        New-Item "$destPart\$PrevYear" -type Directory
    }
    if(Test-Path $destCurrYear){
        #do nothing
    }
    else{
        New-Item "$destPart\$Year" -type Directory    
    }
}


#*********************************************************************
#******FUNCTIONS FOR PREVIOUS DAY, 2 DAYS PRIOR, 3 DAYS PRIOR*********
#*********************************************************************

function CopyNetLogsPrevDay{
    if(test-path "$destFinal\$YestFolder"){
        Write-Host "$destFinal\$YestFolder already exists"
        $destFinRevi = "$destFinal\$YestFolder"
        Get-ChildItem $source | Where-Object{$_.CreationTime -gt $2Date -and $_.CreationTime -lt $Today } | ForEach-Object{copy-item $_.FullName $destFinRevi}
    }
    else{
        new-item "$destFinal\$YestFolder" -type Directory
        $destFinRevi = "$destFinal\$YestFolder"
        Get-ChildItem $source | Where-Object{$_.CreationTime -gt $2Date -and $_.CreationTime -lt $Today } | ForEach-Object{copy-item $_.FullName $destFinRevi}
    }
}

function CopyNetLogs2Days{
    if(test-path "$destFinal\$2DaysFolder"){
        Write-Host "$destFinal\$2DaysFolder already exists"
        $destFinRevi2 = "$destFinal\$2DaysFolder"
        Get-Childitem $source | Where-Object{$_.CreationTime -gt $3Date -and $_.CreationTime -lt $2Date} | ForEach-Object{copy-item $_.FullName $destFinRevi2}
    }
    else{
        new-item "$destFinal\$2DaysFolder" -type Directory
        $destFinRevi2 = "$destFinal\$2DaysFolder"
        Get-Childitem $source | Where-Object{$_.CreationTime -gt $3Date -and $_.CreationTime -lt $2Date} | ForEach-Object{copy-item $_.FullName $destFinRevi2}
    }
}

function CopyNetLogs3Days{
    if(test-path "$destFinal\$3DaysFolder"){
        Write-Host "$destFinal\$3DaysFolder already exists"
        $destFinRevi3 = "$destFinal\$3DaysFolder"
        Get-ChildItem $source | Where-Object{$_.CreationTime -gt $4Date -and $_.CreationTime -lt $3Date} | ForEach-Object{copy-item $_.FullName $destFinRevi3}
    }
    else{
        new-item "$destFinal\$3DaysFolder" -type Directory
        $destFinRevi3 = "$destFinal\$3DaysFolder"
        Get-ChildItem $source | Where-Object{$_.CreationTime -gt $4Date -and $_.CreationTime -lt $3Date} | ForEach-Object{copy-item $_.FullName $destFinRevi3}
    }
}


#******************************************************************************************************
#******************* START OF IF, ElseIf, ElseIf, ElseIf, ElseIF, ElseIF, ELSE STATEMENT***************
#******************************************************************************************************

    #* IF it is JAN & the first of the Month, will pull 3 previous days of backup logs and place them in the correct folders for last month
    #* $test is set to false, if and when it runs successfully, $test will be set to true and a success email will be sent
if($MonthTxtCurr -eq "JAN" -and $DateRevi1 -eq "1"){
    $NewFolder = "$MonthNumPrev - $MonthTxtPrev"

    #** IF, ELSE for Prev, 2 & 3 Day Net Logs
    if(test-path "$destPrevYear\$NewFolder"){
        $test = $false
        $destFinal = "$destPrevYear\$NewFolder"

        CopyNetLogsPrevDay
        CopyNetLogs2Days
        CopyNetLogs3Days
        
        $test = "True"
    }
    else{
        New-Item "$destPrevYear\$NewFolder" -type Directory
        $destFinal = "$destPrevYear\$NewFolder"

        if(Test-Path $destFinal){
            CopyNetLogsPrevDay
            CopyNetLogs2Days
            CopyNetLogs3Days

            $test = "True"
        }
        else{
            $test = "False"
        }
    } #** END Prev, 2 & 3 Day If, Else

    #** IF, ELSE TO SEND MAIL MESSAGE FOR Prev Day, 2Days & 3Days Net Logs
    if($test -eq "True"){
        Send-MailMessage -to name@YOURDOMAIN.com -From name@YOURDOMAIN.com -subject 'Network Backup Log Copy Success' -body "The copy of Network Logs for $2Date, $3Date, & $4Date from XXXX to ArchivedLogs has completed successfully." -smtp smtp.YOURDOMAIN.com
    }
    else{
        Send-MailMessage -to name@YOURDOMAIN.com -From name@YOURDOMAIN.com -subject 'Network Backup Log Copy Failure' -body "The copy of Network Logs for $2Date, $3Date, & $4Date from XXXX to ArchivedLogs has completed successfully.  This indicates there could have been a problem with the Path(s).  Check XXXX for further details." -smtp smtp.YOURDOMAIN.com
    }
}


    #* ELSEIF it is JAN & the 2nd of the Month, will pull 3 previous days of backup logs and place them in the correct folders for last month & this month
    #* $test2 & $test2x are set to false, if and when it runs successfully, $test will be set to true and a success email will be sent
elseif($MonthTxtCurr -eq "JAN" -and $DateRevi1 -eq "2"){
    $test2 = "False"
    $test2x = "False"

    $NewFolder2 = "$MonthNumPrev - $MonthTxtPrev"
    $NewFolder = "$MonthNumCurr - $MonthTxtCurr"

    #** IF, ELSE FOR 2 & 3 Day Net Logs
    if(Test-Path $destPrevYear\$NewFolder2){
        $destFinal = "$destPrevYear\$NewFolder2"

        CopyNetLogs2Days
        CopyNetLogs3Days

        $test2 = "True"
    }
    else{
        New-Item "$destPrevYear\$NewFolder2" -type Directory
        $destFinal = "$destPrevYear\$NewFolder2"

        if(Test-Path $destFinal){
            CopyNetLogs2Days
            CopyNetLogs3Days

            $test2 = "True"
        }
        else{
            $test2 = "False"
        }
    } #** END 2 & 3 Day If, Else

    #** IF, ELSE TO SEND MAIL MESSAGE FOR CopyNetLogs2Days & CopyNetLogs3Days
    if($test2 -eq "True"){
        Send-MailMessage -to name@YOURDOMAIN.com -From name@YOURDOMAIN.com -subject 'Network Backup Log Copy Success' -body "The copy of Network Logs for $3Date, & $4Date from XXXX to ArchivedLogs has completed successfully." -smtp smtp.YOURDOMAIN.com
    }
    else{
        Send-MailMessage -to name@YOURDOMAIN.com -From name@YOURDOMAIN.com -subject 'Network Backup Log Copy Failure' -body "The copy of Network Logs for $3Date, & $4Date from XXXX to ArchivedLogs has completed successfully.  This indicates there could have been a problem with the Path(s).  Check XXXX & XXXX for further details." -smtp smtp.YOURDOMAIN.com
    }

    #** IF, ELSE for Previous Day Net Logs
    if(Test-Path "$destCurrYear\$NewFolder"){
        $destFinal = "$destCurrYear\$NewFolder"

        CopyNetLogsPrevDay

        $test2x = "True"
    }
    else{
        New-Item "$destCurrYear\$NewFolder" -type Directory
        $destFinal = "$destCurrYear\$NewFolder"
        if(Test-Path $destFinal){
            CopyNetLogsPrevDay
            $test2x = "True"
        }
        else{
            $test2x = "False"
        }
    } #** END Previous Day If, Else
    
    #** IF, ELSE TO SEND MAIL MESSAGE FOR CopyNetLogsPrevDay
    if($test2x -eq "True"){
        Send-MailMessage -to name@YOURDOMAIN.com -From name@YOURDOMAIN.com -subject 'Network Backup Log Copy Success' -body "The copy of Network Logs for $2Date from XXXX to ArchivedLogs has completed successfully." -smtp smtp.YOURDOMAIN.com
    }
    else{
        Send-MailMessage -to name@YOURDOMAIN.com -From name@YOURDOMAIN.com -subject 'Network Backup Log Copy Failure' -body "The copy of Network Logs for $2Date from XXXX to ArchivedLogs has completed successfully.  This indicates there could have been a problem with the Path(s).  Check XXXX & XXXX for further details." -smtp smtp.YOURDOMAIN.com
    }
}


    #* ELSEIF it is JAN & the 3rd of the Month, will pull 3 previous days of backup logs and place them in the correct folders for last month & this month
    #* $test3 & $test3x are set to false, if and when it runs successfully, $test will be set to true and a success email will be sent
elseif($MonthTxtCurr -eq "JAN" -and $DateRevi1 -eq "3"){
    $test3 = "False"
    $test3x = "False"
    $NewFolder2 = "$MonthNumPrev - $MonthTxtPrev"
    $NewFolder = "$MonthNumCurr - $MonthTxtCurr"

    #** IF, ELSE FOR 3 Day Net Logs
    if(Test-Path "$destPrevYear\$NewFolder2"){
        $destFinal = "$destPrevYear\$NewFolder2"
        CopyNetLogs3Days
        $test3 = "True"
    }
    else{
        New-Item "$destPrevYear\$NewFolder2" -type Directory
        $destFinal = "$destPart\$NewFolder2"
        if(Test-Path $destFinal){
            CopyNetLogs3Days
            $test3 = "True"
        }
        else{
            $3 = "False"
        }
    }

    #** IF, ELSE TO SEND MAIL MESSAGE FOR 3Days Net Logs
    if($test3 -eq "True"){
        Send-MailMessage -to name@YOURDOMAIN.com -From name@YOURDOMAIN.com -subject 'Network Backup Log Copy Success' -body "The copy of Network Logs for $4Date from XXXX to ArchivedLogs has completed successfully." -smtp smtp.YOURDOMAIN.com
    }
    else{
        Send-MailMessage -to name@YOURDOMAIN.com -From name@YOURDOMAIN.com -subject 'Network Backup Log Copy Failure' -body "The copy of Network Logs for $4Date from XXXX to ArchivedLogs has completed successfully.  This indicates there could have been a problem with the Path(s).  Check XXXX & XXXX for further details." -smtp smtp.YOURDOMAIN.com
    }

    #** IF, ELSE FOR Prev & 2 Day Net Logs
    if(Test-Path "$destCurrYear\$NewFolder"){
        $destFinal = "$destCurrYear\$NewFolder"
        CopyNetLogsPrevDay
        CopyNetLogs2Days
        $test3x = "True"
    }
    else{
        New-Item "$destCurrYear\$NewFolder" -type Directory
        $destFinal = "$destCurrYear\$NewFolder"
        if(Test-Path $destFinal){
            CopyNetLogsPrevDay
            CopyNetLogs2Days
            $test3x = "True"
        }
        else{
            $test3x = "False"
        }
    }

    #** IF, ELSE TO SEND MAIL MESSAGE FOR Prev Day & 2Days Net Logs
    if($test3x -eq "True"){
        Send-MailMessage -to name@YOURDOMAIN.com -From name@YOURDOMAIN.com -subject -subject 'Network Backup Log Copy Success' -body "The copy of Network Logs for $2Date & $3Date from XXXX to ArchivedLogs has completed successfully." -smtp smtp.YOURDOMAIN.com
    }
    else{
        Send-MailMessage -to name@YOURDOMAIN.com -From name@YOURDOMAIN.com -subject -subject 'Network Backup Log Copy Failure' -body "The copy of Network Logs for $2Date & $3Date from XXXX to ArchivedLogs has completed successfully.  This indicates there could have been a problem with the Path(s).  Check XXXX & XXXX for further details." -smtp smtp.YOURDOMAIN.com
    }
}


    #* ELSEIF it is the first of the Month, will pull 3 previous days of backup logs and place them in the correct folders for last month
    #* $1 is set to false, if and when it runs successfully, $1 will be set to true and a success email will be sent
elseif($DateRevi1 -eq "1")
{
    $1 = "False"
    $NewFolder = "$MonthNumPrev - $MonthTxtPrev"

    if(test-path "$destCurrYear\$NewFolder")
    {
        $destFinal = "$destCurrYear\$NewFolder"
        CopyNetLogsPrevDay
        CopyNetLogs2Days
        CopyNetLogs3Days
        $1 = "True"
    }#end if


    else   #*****Else -- If Path does not exist, creates SubFolder for Yesterday and Calls Function*******
    {
        new-item "$destCurrYear\$NewFolder" -type Directory
        $destFinal = "$destCurrYear\$NewFolder"
        if(test-path $destFinal) #**if to test newly created Path, calls functions if true**
        {
            CopyNetLogsPrevDay
            CopyNetLogs2Days
            CopyNetLogs3Days
            $1 = "True"
        }#end if

        else
        { 
            $1 = "False"
        } #end else

    }# end else

    if($1 -eq "True"){
        Send-MailMessage -to name@YOURDOMAIN.com -From name@YOURDOMAIN.com -subject -subject 'Network Backup Log Copy Success' -body "The copy of Network Logs for $2Date, $3Date, & $4Date from XXXX to ArchivedLogs has completed successfully." -smtp smtp.YOURDOMAIN.com
    }
    else{
        Send-MailMessage -to name@YOURDOMAIN.com -From name@YOURDOMAIN.com -subject -subject 'Network Backup Log Copy Failure' -body "The copy of Network Logs for $2Date, $3Date, & $4Date from XXXX to ArchivedLogs has completed successfully.  This indicates there could have been a problem with the Path(s).  Check XXXX & XXXX for further details." -smtp smtp.YOURDOMAIN.com
    }
}


    #* ElseIF it is the second of the Month, will pull 3 previous days of backup logs and place them in the correct folders for last month & this month
    #* $2 is set to false, if and when it runs successfully, $2 will be set to true and a success email will be sent
elseif($DateRevi1 -eq "2") 
{
    $2 = "False"
    $2x = "False"
    $NewFolder2 = "$MonthNumPrev - $MonthTxtPrev"
    $NewFolder = "$MonthNumCurr - $MonthTxtCurr"

    if(test-path "$destCurrYear\$NewFolder2")
    {
        $destFinal = "$destCurrYear\$NewFolder2"
        
        CopyNetLogs2Days
        CopyNetLogs3Days
        $2 = "True"
    }#end if


    else   #*****Else -- If Path does not exist, creates SubFolder for Yesterday and Calls Function*******
    {
        new-item "$destCurrYear\$NewFolder2" -type Directory
        $destFinal = "$destCurrYear\$NewFolder2"
        if(test-path $destFinal) #**if to test newly created Path, calls function if true**
        {
            
            CopyNetLogs2Days
            CopyNetLogs3Days
            $2 = "True"
        }#end if

        else   #**if the path does not test true, failure email sent**
        {
            $2 = "False" 
        } #end else

    }# end else

    if($2 -eq "True"){
        Send-MailMessage -to name@YOURDOMAIN.com -From name@YOURDOMAIN.com -subject 'Network Backup Log Copy Success' -body "The copy of Network Logs for $3Date, & $4Date from XXXX to ArchivedLogs has completed successfully." -smtp smtp.YOURDOMAIN.com
    }
    else{
        Send-MailMessage -to name@YOURDOMAIN.com -From name@YOURDOMAIN.com -subject 'Network Backup Log Copy Failure' -body "The copy of Network Logs for $3Date, & $4Date from XXXX to ArchivedLogs has completed successfully.  This indicates there could have been a problem with the Path(s).  Check XXXX & XXXX for further details." -smtp smtp.YOURDOMAIN.com
    }

    if(test-path "$destCurrYear\$NewFolder")
    {
        $destFinal = "$destCurrYear\$NewFolder"
        CopyNetLogsPrevDay
        $2x = "True"
        
    }#end if

    else   #*****Else -- If Path does not exist, creates SubFolder for Yesterday and Calls Function*******
    {
        new-item "$destCurrYear\$NewFolder" -type Directory
        $destFinal = "$destCurrYear\$NewFolder"
        if(test-path $destFinal) #**if to test newly created Path, calls function if true**
        {
            CopyNetLogsPrevDay
            $2x = "True"
           
        }#end if

        else   #**if the path does not test true, failure email sent**
        {
            $2x = "False" 
        } #end else

    }# end else

    if($2x -eq "True"){
        Send-MailMessage -to name@YOURDOMAIN.com -From name@YOURDOMAIN.com -subject 'Network Backup Log Copy Success' -body "The copy of Network Logs for $2Date from XXXX to ArchivedLogs has completed successfully." -smtp smtp.YOURDOMAIN.com
    }
    else{
        Send-MailMessage -to name@YOURDOMAIN.com -From name@YOURDOMAIN.com -subject 'Network Backup Log Copy Failure' -body "The copy of Network Logs for $2Date from XXXX to ArchivedLogs has completed successfully.  This indicates there could have been a problem with the Path(s).  Check XXXX & XXXX for further details." -smtp smtp.YOURDOMAIN.com
    }
}


    #* ElseIF it is the third of the Month, will pull 3 previous days of backup logs and place them in the correct folders for last month & this month
    #* $3 is set to false, if and when it runs successfully, $1 will be set to true and a success email will be sent
elseif($DateRevi1 -eq "3")
{
    $3 = "False"
    $3x = "False"
    $NewFolder2 = "$MonthNumPrev - $MonthTxtPrev"
    $NewFolder = "$MonthNumCurr - $MonthTxtCurr"

    if(test-path "$destCurrYear\$NewFolder2")
    {
        $destFinal = "$destCurrYear\$NewFolder2"
        CopyNetLogs3Days
        $3 = "True"
    }#end if


    else   #*****Else -- If Path does not exist, creates SubFolder for Yesterday and Calls Function*******
    {
        new-item "$destCurrYear\$NewFolder2" -type Directory
        $destFinal = "$destCurrYear\$NewFolder2"
        if(test-path $destFinal) #**if to test newly created Path, calls function if true**
        {
            CopyNetLogs3Days
            $3 = "True"
        }#end if

        else   #**if the path does not test true, failure email sent**
        {
            $3 = "False" 
        } #end else

    }# end else

    if($3 -eq "True"){
        Send-MailMessage -to name@YOURDOMAIN.com -From name@YOURDOMAIN.com -subject 'Network Backup Log Copy Success' -body "The copy of Network Logs for $4Date from XXXX to ArchivedLogs has completed successfully." -smtp smtp.YOURDOMAIN.com
    }
    else{
        Send-MailMessage -to name@YOURDOMAIN.com -From name@YOURDOMAIN.com -subject 'Network Backup Log Copy Failure' -body "The copy of Network Logs for $4Date from XXXX to ArchivedLogs has completed successfully.  This indicates there could have been a problem with the Path(s).  Check XXXX & XXXX for further details." -smtp smtp.YOURDOMAIN.com
    }

    if(test-path "$destCurrYear\$NewFolder")
    {
        $destFinal = "$destCurrYear\$NewFolder"
        CopyNetLogsPrevDay
        CopyNetLogs2Days
        $3x = "True"
    }#end if


    else   #*****Else -- If Path does not exist, creates SubFolder for Yesterday and Calls Function*******
    {
        new-item "$destCurrYear\$NewFolder" -type Directory
        $destFinal = "$destCurrYear\$NewFolder"
        if(test-path $destFinal) #**if to test newly created Path, calls function if true**
        {
            CopyNetLogsPrevDay
            CopyNetLogs2Days
            $3x = "True"
        }#end if

        else   #**if the path does not test true, failure email sent**
        {
            $3x = "False" 
        } #end else

    }# end else

    if($3x -eq "True"){
        Send-MailMessage -to name@YOURDOMAIN.com -From name@YOURDOMAIN.com -subject 'Network Backup Log Copy Success' -body "The copy of Network Logs for $2Date & $3Date from XXXX to ArchivedLogs has completed successfully." -smtp smtp.YOURDOMAIN.com
    }
    else{
        Send-MailMessage -to name@YOURDOMAIN.com -From name@YOURDOMAIN.com -subject 'Network Backup Log Copy Failure' -body "The copy of Network Logs for $2Date & $3Date from XXXX to ArchivedLogs has completed successfully.  This indicates there could have been a problem with the Path(s).  Check XXXX & XXXX for further details." -smtp smtp.YOURDOMAIN.com
    }
}


    #* Else it is any other day of the Month, will pull 3 previous days of backup logs and place them in the correct folders for this month
    #* $4 is set to false, if and when it runs successfully, $1 will be set to true and a success email will be sent
else
{
    $4 = "False"
    $NewFolder = "$MonthNumCurr - $MonthTxtCurr"

    if(test-path "$destCurrYear\$NewFolder")
    {
        $destFinal = "$destCurrYear\$NewFolder"
        CopyNetLogsPrevDay
        CopyNetLogs2Days
        CopyNetLogs3Days
        $4 = "True"
    }#end if


    else   #*****Else -- If Path does not exist, creates SubFolder for Yesterday and Calls Function*******
    {
        new-item "$destCurrYear\$NewFolder" -type Directory
        $destFinal = "$destCurrYear\$NewFolder"
        if(test-path $destFinal) #**if to test newly created Path, calls function if true**
        {
            CopyNetLogsPrevDay
            CopyNetLogs2Days
            CopyNetLogs3Days
            $4 = "True"
        }#end if

        else   #**if the path does not test true, failure email sent**
        {
            $4 = "False" 
            #Send-MailMessage -to name@YOURDOMAIN.com -From name@YOURDOMAIN.com -subject 'Network Log Copy Failure - XXXX' -body "The copy of Network Logs for $Yesterday from XXXX to XXXX has completed successfully.  This indicates the Path(s) have failed or there were no Network Logs to copy.  Check XXXX & XXXX for further details." -smtp smtp.YOURDOMAIN.com
        } #end else

    }# end else

    if($4 -eq "True"){
        Send-MailMessage -to name@YOURDOMAIN.com -From name@YOURDOMAIN.com -subject 'Network Backup Log Copy Success' -body "The copy of Network Logs for $2Date, $3Date, & $4Date from XXXX to ArchivedLogs has completed successfully." -smtp smtp.YOURDOMAIN.com
    }
    else
    {
        Send-MailMessage -to name@YOURDOMAIN.com -From name@YOURDOMAIN.com -subject 'Network Backup Log Copy Failure' -body "The copy of Network Logs for $2Date, $3Date, & $4Date from XXXX to ArchivedLogs has completed successfully.  This indicates there could have been a problem with the Path(s).  Check XXXX & XXXX for further details." -smtp smtp.YOURDOMAIN.com
    }
}
#******************* END OF IF, ElseIF, ElseIf, ElseIF, ElseIF, ELSE STATEMENT***************



#******************* 01/10/19 CJC **********************
#* Below Process will zip the previous, previous Month's folder
#* Test-path after zip to ensure it is there, if so removes the folder that was just zipped
#* If Test-path fails, alerts admins and does not remove the folder 
#*******************************************************

$PrevPrevMonthTxt = (Get-Date).AddMonths(-2).ToString('MMM')
$PrevPrevMonthNum = (Get-Date).AddMonths(-2).Month
$Folder2Zip = "$PrevPrevMonthNum - $PrevPrevMonthTxt"

#If the current month is Jan & the date is the 1st, this will zip the previous years Novemember folder
if($MonthTxtCurr -eq "JAN" -and $DateRevi1 -eq "1"){

    Compress-Archive -Path $destPrevYear\$Folder2Zip -CompressionLevel Optimal -DestinationPath $destPrevYear\$Folder2Zip.zip
    
    if(test-path("$destPrevYear\$Folder2Zip.zip")){
        
        Remove-Item -Path $destPrevYear\$Folder2Zip -Recurse
        Send-MailMessage -to name@YOURDOMAIN.com -From name@YOURDOMAIN.com -subject 'XXXX Net Log Zip Success' -body "Zip of $destPrevYear\$Folder2Zip has complete & $Folder2Zip has been removed." -smtp smtp.YOURDOMAIN.com

    }
    else{
        Send-MailMessage -to name@YOURDOMAIN.com -From name@YOURDOMAIN.com -subject 'XXXX Net Log Zip Failure' -body "Zip of $destPrevYear\$Folder2Zip has failed, please investigate and manually complete the process" -smtp smtp.YOURDOMAIN.com
    }
}

#elseIf the current month is Feb & the date is the 1st, this will zip the previous years December folder
elseif($MonthTxtCurr -eq "FEB" -and $DateRevi1 -eq "1"){
    
    #zip the previous to the previous Month's files
    Compress-Archive -Path $destPrevYear\$Folder2Zip -CompressionLevel Optimal -DestinationPath $destPrevYear\$Folder2Zip.zip
    
    if(test-path("$destPrevYear\$Folder2Zip.zip")){

        Remove-Item -Path $destPrevYear\$Folder2Zip -Recurse
        Send-MailMessage -to name@YOURDOMAIN.com -From name@YOURDOMAIN.com -subject 'XXXX Net Log Zip Success' -body "Zip of $destPrevYear\$Folder2Zip has complete & $Folder2Zip has been removed." -smtp smtp.YOURDOMAIN.com

    }
    else{
        Send-MailMessage -to name@YOURDOMAIN.com -From name@YOURDOMAIN.com -subject 'XXXX Net Log Zip Failure' -body "Zip of $destPrevYear\$Folder2Zip has failed, please investigate and manually complete the process" -smtp smtp.YOURDOMAIN.com
    }
}

#elseIf the current month is anything but Jan or Feb & the date is the 1st, this will zip the previous, previous Month's folder
elseif($DateRevi1 -eq "1"){
    
    #zip the previous to the previous Month's files
    Compress-Archive -Path $destCurrYear\$Folder2Zip -CompressionLevel Optimal -DestinationPath $destCurrYear\$Folder2Zip.zip
    
    if(test-path("$destCurrYear\$Folder2Zip.zip")){
        
        Remove-Item -Path $destCurrYear\$Folder2Zip -Recurse
        Send-MailMessage -to name@YOURDOMAIN.com -From name@YOURDOMAIN.com -subject 'XXXX Net Log Zip Success' -body "Zip of $destCurrYear\$Folder2Zip has complete & $Folder2Zip has been removed." -smtp smtp.YOURDOMAIN.com

    }
    else{
        Send-MailMessage -to name@YOURDOMAIN.com -From name@YOURDOMAIN.com -subject 'XXXX Net Log Zip Failure' -body "Zip of $destCurrYear\$Folder2Zip has failed, please investigate and manually complete the process" -smtp smtp.YOURDOMAIN.com
    }
}

#Else, do a holada nada
else{
    #do a holada nada
}

#****************************************************************************
#*****************************END SCRIPT*************************************
#****************************************************************************