#ps1_sysnative

# Template variables
$user='${instance_user}'
$password='${instance_password}'
$computerName='${instance_name}'

Write-Output "Changing $user password"
net user $user $password
Write-Output "Changed $user password"
