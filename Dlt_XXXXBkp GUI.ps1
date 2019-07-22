$source = "C:\temp\New Folder"
$limit = (Get-Date).AddDays(-61)

function GenerateForm
{
    [reflection.assembly]::loadwithpartialname("System.Windows.Forms") | Out-Null
    [reflection.assembly]::LoadWithPartialName("System.Drawing") | Out-Null

    #Gen Form Objects Region
    $HelpDeskForm = New-Object System.Windows.Forms.Form
    $BoxLabel = New-Object System.Windows.Forms.Label

    $YesTextBox = New-Object System.Windows.Forms.TextBox
    $NoTestBox = New-Object System.Windows.Forms.TextBox

    $YesButton = New-Object System.Windows.Forms.Button
    $NoButton = New-Object System.Windows.Forms.Button
    $NewButton = New-Object System.Windows.Forms.Button
   

    $InitialFormWindowState = New-Object System.Windows.Forms.FormWindowState
    $InitialFormWindowState2 = New-Object System.Windows.Forms.FormWindowState
    #End Gen Form Objects

    $handler_YesButton_Click=
    {
        #custom script here
        $source = "C:\temp\New Folder"
        $limit = (Get-Date).AddDays(-61)

        try{
            if(-not(test-path $source))
            {
                Throw "Uh-oh there seems to be an error w/ the current path : $source"
            }
   
            else{
                Get-ChildItem -Path $source -Recurse -Force | Where-Object { !$_.PSIsContainer -and $_.lastwritetime -lt $limit } | Remove-Item -Force
                $YesForm.ShowDialog()
            }
    
    
        }#end try
        catch{
             $_
             Pause
        }#end catch 
    }#end handler

    $handler_NewButton_Click =
    {
        $YesForm.Close()
        $HelpDeskForm.Close()
    }

    $handler_NoButton_Click=
    {
        #end script here
        $HelpDeskForm.Close()
    }

    $OnLoadForm_StateCorrection = 
    {
        #Correct the initial state of the form to prevent the .Net maximized form issue
        $HelpDeskForm.WindowState = $InitialFormWindowState
    }
    $OnLoadForm_StateCorrection2 =
    {
        $YesForm.WindowState = $InitialFormWindowState2
    }

    #Gen Form Code Region
    #------FORM--------------
    $HelpDeskForm.text = "Erase XXXX Back Up Logs"
    $HelpDeskForm.name = "HelpDeskForm"
    $HelpDeskForm.DataBindings.DefaultDataSourceUpdateMode = 0
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Width = 300
    $System_Drawing_Size.height = 110
    $HelpDeskForm.ClientSize = $System_Drawing_Size

    #-----------YES BUTTON-------------
    $YesButton.TabIndex = 0
    $YesButton.Name = "YesButton"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Width = 100
    $System_Drawing_Size.Height = 23
    $YesButton.Size = $System_Drawing_Size
    $YesButton.UseVisualStyleBackColor = $True

    $YesButton.Text = "Yes"

    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 37
    $System_Drawing_Point.Y = 75
    $YesButton.Location = $System_Drawing_Point
    $YesButton.DataBindings.DefaultDataSourceUpdateMode = 0
    $YesButton.add_Click($handler_YesButton_Click)

    #-----------NO BUTTON-------------
    $NoButton.TabIndex = 0
    $NoButton.Name = "YesButton"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Width = 100
    $System_Drawing_Size.Height = 23
    $NoButton.Size = $System_Drawing_Size
    $NoButton.UseVisualStyleBackColor = $True

    $NoButton.Text = "Cancel"

    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 165
    $System_Drawing_Point.Y = 75
    $NoButton.Location = $System_Drawing_Point
    $NoButton.DataBindings.DefaultDataSourceUpdateMode = 0
    $NoButton.add_Click($handler_NoButton_Click)

    #------------BoxLabel------------
    $BoxLabel.TabIndex = 0
    $BoxLabel.Name = "BoxLabel"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Width = 300
    $System_Drawing_Size.Height = 60
    $BoxLabel.Size = $System_Drawing_Size

    $BoxLabel.text = "This will erase files in $source that are older than $limit.

            Are you sure you would like to continue?"

    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 10
    $System_Drawing_point.Y = 10
    $BoxLabel.Location = $System_Drawing_Point

    #------YES FORM--------
    $YesForm = New-Object System.Windows.Forms.Form
    $YesForm.text = "Alert!"
    $YesForm.name = "YesForm"
    $YesForm.DataBindings.DefaultDataSourceUpdateMode = 0
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Width = 200
    $System_Drawing_Size.Height = 100
    $YesForm.ClientSize = $System_Drawing_Size
    #-------YesLabel---------
    $YesLabel = New-Object System.Windows.Forms.Label
    $YesLabel.TabIndex = 0
    $YesLabel.Name = "2 Box Label"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Width = 200
    $System_Drawing_Size.Height = 100
    $YesLabel.Size = $System_Drawing_Size

    $YesLabel.text = "    Backup Log erase is Complete!
    
                Happy Holidays!"

    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 10
    $System_Drawing_Point.Y = 10
    $YesLabel.Location = $System_Drawing_Point

           #-----------NEW BUTTON-------------
    $NewButton.TabIndex = 0
    $NewButton.Name = "YesButton"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Width = 75
    $System_Drawing_Size.Height = 23
    $NewButton.Size = $System_Drawing_Size
    $NewButton.UseVisualStyleBackColor = $True

    $NewButton.Text = "Ok"

    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 60
    $System_Drawing_Point.Y = 65
    $NewButton.Location = $System_Drawing_Point
    $NewButton.DataBindings.DefaultDataSourceUpdateMode = 0
    $NewButton.add_Click($handler_NewButton_Click)

    #---------------------------------------
    $HelpDeskForm.Controls.Add($YesButton)
    $HelpDeskForm.Controls.Add($NoButton)
    $HelpDeskForm.Controls.Add($BoxLabel)

    $YesForm.Controls.Add($NewButton)
    $YesForm.Controls.Add($YesLabel)


     #endregion Generated Form Code




    #Save the initial state of the form 
    $InitialFormWindowState = $HelpDeskForm.WindowState
    $InitialFormWindowState2 = $YesForm.WindowState
    #Init the OnLoad event to correct the initial state of the form 
    $HelpDeskForm.add_Load($OnLoadForm_StateCorrection)
    $YesForm.add_Load($OnLoadForm_StateCorrection2)
    #Show the Form 
    $HelpDeskForm.ShowDialog()| Out-Null

} #End Function

#Call the Function 
GenerateForm 