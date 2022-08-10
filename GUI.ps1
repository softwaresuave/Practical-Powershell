Add-Type -AssemblyName system.windows.forms

$main_form = New-Object system.windows.forms.form
$main_form.Text = 'GUI for my Powershell script'
$main_form.Width = 600
$main_form.Height = 500
#$main_form.ShowDialog()


$Label = New-Object System.Windows.Forms.Label
$Label.Text = "AD users"
$Label.Location  = New-Object System.Drawing.Point(0,10)
$Label.AutoSize = $true

$main_form.Controls.Add($Label) 


$ComboBox = New-Object System.Windows.Forms.ComboBox
$ComboBox.Width = 300
<#$Users = get-aduser -filter * -Properties SamAccountName
Foreach ($User in $Users)
    {
    $ComboBox.Items.Add($User.SamAccountName);
    }#>
$ComboBox.Location  = New-Object System.Drawing.Point(60,10)
$main_form.Controls.Add($ComboBox)



$Button = New-Object System.Windows.Forms.Button
$Button.Location = New-Object System.Drawing.Size(400,10)
$Button.Size = New-Object System.Drawing.Size(120,23)
$Button.Text = "Check"
$main_form.Controls.Add($Button)



$main_form.ShowDialog()owDialog()