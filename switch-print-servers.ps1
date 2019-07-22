<#
    .SYNOPSIS
        Logon Script to migrate printer mapping
    
    .DESCRIPTION
        Logon Script to migrate printer mappings
#>
Param (
    $newPrintServer = "XXXX",
    $PrinterLog = "c:\temp\PrintMigration.csv"
)
<#
    #Header for CSV log file:
    "COMPUTERNAME,USERNAME,PRINTERNAME,RETURNCODE-ERRORMESSAGE,DATETIME,STATUS" | 
        Out-File -FilePath $PrinterLog -Encoding ASCII
#>
Try {
    Write-Verbose ("{0}: Checking for printers mapped to old print server" -f $Env:USERNAME)
    $printers = @(Get-WmiObject -Class Win32_Printer -Filter "SystemName='\\\\XXXX'" -ErrorAction Stop)
    
    If ($printers.count -gt 0) {        
        ForEach ($printer in $printers) {
            Write-Verbose ("{0}: Replacing with new print server name: {1}" -f $Printer.Name,$newPrintServer)
            $newPrinter = $printer.Name -replace "XXXX",$newPrintServer  
            $returnValue = ([wmiclass]"Win32_Printer").AddPrinterConnection($newPrinter).ReturnValue                
            If ($returnValue -eq 0) {
                "{0},{1},{2},{3},{4},{5}" -f $Env:COMPUTERNAME,
                                             $env:USERNAME,
                                             $newPrinter,
                                             $returnValue,
                                             (Get-Date),
                                             "Added Printer" | Out-File -FilePath $PrinterLog -Append -Encoding ASCII            
                Write-Verbose ("{0}: Removing" -f $printer.name)
                $printer.Delete()
                "{0},{1},{2},{3},{4},{5}" -f $Env:COMPUTERNAME,
                                             $env:USERNAME,
                                             $printer.Name,
                                             $returnValue,
                                             (Get-Date),
                                             "Removed Printer" | Out-File -FilePath $PrinterLog -Append -Encoding ASCII
            } Else {
                Write-Verbose ("{0} returned error code: {1}" -f $newPrinter,$returnValue) -Verbose
                "{0},{1},{2},{3},{4},{5}" -f $Env:COMPUTERNAME,
                                             $env:USERNAME,
                                             $newPrinter,
                                             $returnValue,
                                             (Get-Date),
                                             "Error Adding Printer" | Out-File -FilePath $PrinterLog -Append -Encoding ASCII
            }
        }
    }
} Catch {
    "{0},{1},{2},{3},{4},{5}" -f $Env:COMPUTERNAME,
                                 $env:USERNAME,
                                 "WMIERROR",
                                 $_.Exception.Message,
                                 (Get-Date),
                                 "Error Querying Printers" | Out-File -FilePath $PrinterLog -Append -Encoding ASCII
}
