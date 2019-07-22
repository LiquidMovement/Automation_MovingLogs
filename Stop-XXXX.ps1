<### Used to Stop the XXXX Service.  
Can be modified for any service.
###>

$logdate = Get-Date -f MMddyyy
$processname = "XXXX"
$servicename = 'XXXX'
$log = "C:\XXXX\logs\XXXX-stop-log_$logdate.txt"
$recipients = @("name@YOURDOMAIN.com", "name@YOURDOMAIN.com")

#*** FUNCTIONS ***#

function logmessage ([string]$message){

    $timestamp = Get-Date -f MM-dd-yyyy_HH:mm:ss
    Write-Output "$timestamp - $message" | Out-File $log -Append

} #endfunc


function num2StopService{

	If (!((Get-Service -Name $servicename | select -ExpandProperty 'status') -eq "Stopped")){
		Write-host "Service did not stop, Forcing"
		logmessage("Service did not stop, attempting Force Stop.")

		Stop-Service -Name $servicename -Force
	}
	else{
		logmessage("Service stopped successfully, ending script")
		exit
	}

}


function stopProcess{

	If (!((Get-Service -Name $servicename | select -ExpandProperty 'status') -eq "Stopped")){

		Write-Host "Killing Process via ID"
		logmessage("Service did not stop by force, attempting force stop on process ID.")
		$PID = Get-Process -Name $processname | select -ExpandProperty 'id'
		Stop-Process -id $PID -Force
        
        logmessage("Stop Process w/ ID sent, waiting 5 minutes to re-check")
        Start-Sleep -Seconds 300
    }
	else{
	    logmessage("Service stopped successfully, ending script")
		exit
	}

}


function failCheck{

	If (!((Get-Service -Name $servicename | select -ExpandProperty 'status') -eq "Stopped")){

		logmessage("Service/Process did not stop, needs manual investigation.")
		Send-MailMessage -to $recipients -From name@YOURDOMAIN.com -subject 'XXXX FAILED TO STOP - 	INVESTIGATE' -body 'Neither the Service nor the Process stopped gracefully, see log attached & investigate. Process needs to be stopped before XXXX Save runs.' -smtp smtp.YOURDOMAIN.com -Attachments $log
		Start-Sleep -Seconds 10
		Exit
	}
	else{
		logmessage("Service stopped successfully, ending script")
		exit
	}

}


#*** START MAIN SCRIPT ***#
If ((Get-Service -Name $servicename | select -ExpandProperty 'status') -eq "Stopped"){
    Write-Host "Service not running" 
    logmessage("Service not running, ending script")
    Send-MailMessage -to $recipients -From name@YOURDOMAIN.com -subject 'XXXX Not running' -body 'XXXX Service was not running, so therefore could not be stopped.  Is this an issue?' -smtp smtp.YOURDOMAIN.com -Attachments $log
    exit
}
else{
    logmessage("Service Status is currently Running or Stopping, attempting to stop")
    Stop-Service -Name $servicename
} #end if-else

logmessage("First stop sent, waiting 5 minutes to re-check")
Start-Sleep -Seconds 300

num2StopService
Start-Sleep -Seconds 60

stopProcess

failCheck

#*** END MAIN SCRIPT ***#