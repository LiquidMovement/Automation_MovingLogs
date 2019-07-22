<### Used to restart the XXXX Service.  
Can be modified for any service.

###>

$logdate = Get-Date -f MMddyyy
$processname = "XXXX"
$servicename = 'XXXX'
$log = "C:\XXXX-service_control\logs\XXXX-start-log_$logdate.txt"
$recipients = @("name@YOURDOMAIN.com", "name@YOURDOMAIN.com")

function logmessage ([string]$message) {

    $timestamp = Get-Date -f MM-dd-yyyy_HH:mm:ss
    Write-Output "$timestamp - $message" | Out-File $log -Append

} #endfunc


function startservice {

    Write-Host "Attempting to start service..." 
    logmessage("Attempting to start service...")
    Start-Service $servicename

}


function checkservice {
    
    if((Get-Service -name $servicename | select -ExpandProperty 'status') -eq "Stopping"){
        logmessage("$servicename stuck in Stopping state after attempted PID kill. Script will now exit & abort attempting to Start the Service until an admin can manually investigate.")
        Send-MailMessage -to $recipients -From name@YOURDOMAIN.com -subject 'XXXX Stuck Stopping' -body 'XXXX Service is stuck in a Stopping state. Start XXXX script terminated. PortalSync needs to be investigated. This is an issue!!' -smtp smtp.YOURDOMAIN.com -Attachments $log
        exit
    }
    elseIf((Get-Service -Name $servicename | select -ExpandProperty 'status') -eq "Running")
    {
        logmessage("Service is running, No need to start!  Ending script.")
        exit
    }
    else{
           startservice
    } #end if-else

}


#*** CJC 1/8/18 - Function to check if the Service is stuck in a Stopping State. ***#
#*** If so, will attempt to force stop the Process via process id ***#
function checkStopping{

    if((Get-Service -name $servicename | select -ExpandProperty 'status') -eq "Stopping"){

        logmessage("$servicename stuck in Stopping state. Attempting to force kill the process with the PID.")
        $PID = Get-Process -Name $processname | select -ExpandProperty 'id'
		Stop-Process -id $PID -Force
    }
}


#*** START MAIN SCRIPT ***#

checkStopping
Start-Sleep -Seconds 120

checkservice
logmessage("Waiting to see if service started - attempt 1.")
Start-Sleep -Seconds 60

checkservice
logmessage("Waiting to see if service started - attempt 2.")
Start-Sleep -Seconds 60

checkservice
logmessage("Waiting to see if service started - attempt 3.")
Start-Sleep -Seconds 60

If((Get-Service -Name $servicename | select -ExpandProperty 'status') -eq "Running"){

    logmessage("Service is running, No need to start!  Ending script.")
}
else{

    logmessage("Service is not starting!  Investigate XXXX!")
    Send-MailMessage -to $recipients -From name@YOURDOMAIN.com -subject 'XXXX Not Starting' -body 'XXXX Service is not starting.  This is an issue!!' -smtp smtp.YOURDOMAIN.com -Attachments $log

}

#*** END MAIN SCRIPT ***#