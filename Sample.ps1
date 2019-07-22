function Invoke-IEWait{
    [cmdletbinding()]
    Param(
        [Parameter(
            Mandatory,
            ValueFromPipeline
        )]
        $ieObject
    )
    
    While($ieObject.Busy){

        Start-Sleep -Milliseconds 250
    }


}

function Invoke-Cleanup{
    $ieObject.quit()
    [void][Runtime.Interopservices.Marshal]::ReleaseComObject($ieObject)

}

#create new IE instance and browse to URL // bring to front
#$ieObject = New-Object -ComObject 'InternetExplorer.Application'
#$ieObject | Get-Member
#$ieObject.Visible = $true
#$ieObject.Navigate('https://www.ENTERADDRESS.com')

Invoke-IEWait

#Get Elements of current page
$currentDoc = $ieObject.Document
$currentDoc.IHTMLDocument3_getElementsByTagName("input") | Select-Object Type,Name

#Gather links
#$currentDoc.links | Select-Object outerText,href

#Gather just download link
#$downloadLink = $currentDoc.links | Where-Object {$_.outerText -eq 'Download'} | Select-Object -ExpandProperty href #add 'href -First 1' if there are multiple
#$downloadLink

#$uNameBox = $currentDoc.IHTMLDocument3_getElementsByTagName("input") | Where-Object {$_.name -eq "usernameTextBox"}
#$uNameBox.value = 'testUser@YOURDOMAIN.com'


for($i=1; $i -le 254; $i++){
    $ipBox1 = $currentDoc.IHTMLDocument3_getElementsByTagName("input") | Where-Object {$_.name -eq 'ctl00$cph$ipTextBox1'}
    $ipBox1.value = 'XXX'

    $ipBox2 = $currentDoc.IHTMLDocument3_getElementsByTagName("input") | Where-Object {$_.name -eq 'ctl00$cph$ipTextBox2'}
    $ipBox2.value = 'XXX'

    $ipBox3 = $currentDoc.IHTMLDocument3_getElementsByTagName("input") | Where-Object {$_.name -eq 'ctl00$cph$ipTextBox3'}
    $ipBox3.value = 'XXX'

    $ipBox4 = $currentDoc.IHTMLDocument3_getElementsByTagName("input") | Where-Object {$_.name -eq 'ctl00$cph$ipTextBox4'}
    $ipBox4.value = $i

    #Gather submit button into variable
    $submitBtn = $currentDoc.IHTMLDocument3_getElementsByTagName('input') | Where-Object {$_.type -eq 'submit'}
    #$submitBtn | Get-Member -MemberType Method
    
    #'click' submit button
    $submitBtn.click()

    #sleep
    sleep -Milliseconds 250

    #reset currentDoc to current page after click
    $currentDoc = $ieObject.Document
    
    #invoke IEWait function
    Invoke-IEWait -ieObject $currentDoc
}

#invoke cleanup function
Invoke-Cleanup