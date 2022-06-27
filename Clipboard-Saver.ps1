Add-Type -AssemblyName System.Windows.Forms

$clipboard = [System.Windows.Forms.Clipboard]
$filter = ""
$type = $null
$data = ""

##############################################################
if($clipboard::ContainsImage()){
    $type = "Image"
    $data = $clipboard::getImage()
    $filter = "Png Image (.png)|*.png|JPEG Image (.jpg)|*.jpg|Bitmap Image (.bmp)|*.bmp|Gif Image (.gif)|*.gif|Tiff Image (.tiff)|*.tiff|Wmf Image (.wmf)|*.wmf|All files (*.*)|*.*"

}elseif($clipboard::ContainsText()){
    $type = "Text"
    $data = $clipboard::GetText()
    $filter = "Text files (*.txt)|*.txt|All files (*.*)|*.*"

}elseif($clipboard::ContainsAudio()){
    $type = "Audio"
    $data = $clipboard::GetAudioStream()
    $filter = "MP3 (.mp3)|*.mp3|WAV (.wav)|*.wav|FLAC (.flac)|*.flac|AAC (.aac)|*.aac|OGG (.ogg)|*.ogg|All files (*.*)|*.*"

}elseif($clipboard::ContainsFileDropList()){
    # it saves paths of selected file/s
    $type = "FileDropList"
    $data = $clipboard::GetFileDropList()
    $filter = "Text files (*.txt)|*.txt|All files (*.*)|*.*"
}else{
    # show notification
    $notif = new-object system.windows.forms.notifyicon
    $notif.icon = [System.Drawing.SystemIcons]::Information
    $notif.visible = $true
    $notif.ShowBalloonTip(0,"", "No data in clipboard",[system.windows.forms.tooltipicon]::None)
    return
}
##############################################################
#
#
################## Save file dialog ##########################
$SaveFileDialog = New-Object System.Windows.Forms.SaveFileDialog
$SaveFileDialog.Title = "Paste as"

$SaveFileDialog.filter = $filter
$SaveFileDialog.FileName = "clipboard_{0}" -f ((Get-Date -Format s) -replace 'T','_' -replace ':', '')

if($SaveFileDialog.ShowDialog() -eq "OK") {
    # return selecter path
    $file = $SaveFileDialog.FileName
}else{
    return
}
##############################################################
#
#
################## Saving file ###############################
switch($type){
    "Image" {$data.save($file);break}
    "Text" {$data > $file;break}
    "Audio" {[io.file]::WriteAllBytes($file, $data.ToArray());break}
    "FileDropList" {$data > $file;break}
    default {return}
}
##############################################################
#
#
################## Printing details ##########################
#Write-Host "File type: $type"
#Write-Host "File path: $file"
##############################################################

# open explorer in the file location and select it
# & explorer.exe /select,$file