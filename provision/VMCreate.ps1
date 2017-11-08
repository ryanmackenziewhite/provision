Param(
    [int]$numVMs = 1,
    [boolean]$namenode = $false,
    [int]$storage = 32768
)

$cwd = Get-Location | Select-Object -exp Path
Set-Variable -Name "VBPath" -Value "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"
$NetAdapter = Get-NetAdapter -Physical | Select-Object -exp InterfaceDescription
$index = 0

if($namenode)
{
    $ram = 8192
}
else {
    $ram = 2048
}

while($index -lt $numVMs)
{
    Set-Variable -Name "VM" -Value "LinuxHadoop$index"
    New-Item -ItemType "Directory" -Force -Path "C:\Users\$env:USERNAME\VirtualBox VMs\$VM"
    Set-Location -Path "C:\Users\$env:USERNAME\VirtualBox VMs\$VM"
    
    & "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" createhd --filename "$VM.vdi" --size $storage

    & "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" createvm --name $VM --ostype "Fedora_64" --register

    & "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" storagectl $VM --name "SATA Controller" --add sata --controller IntelAHCI
    & "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" storageattach $VM --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "$VM.vdi"

    & "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" storagectl $VM --name "IDE Controller" --add ide
    & "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" storageattach $VM --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium C:\Users\dopar\Downloads\Fedora-Server-dvd-x86_64-26-1.5.iso

    & "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" modifyvm $VM --ioapic on
    & "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" modifyvm $VM --boot1 dvd --boot2 disk --boot3 none --boot4 none
    & "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" modifyvm $VM --memory $ram --vram 128
    & "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" modifyvm $VM --nic1 bridged --bridgeadapter1 $NetAdapter

    $index = $index + 1
}

Set-Location $cwd