
param(
    [string]$EC2IP,
    [string]$User = "ec2-user",
    [string]$KeyPath,
    [string]$Repo,
    [int]$NumRunners = 1
)

for ($i=1; $i -le $NumRunners; $i++) {
    $RunnerFolder = "runner$i"
    Write-Host "Setting up runner $i in folder $RunnerFolder on EC2 $EC2IP"

    $Commands = @"
    mkdir -p ~/actions-runner/$RunnerFolder
    cd ~/actions-runner/$RunnerFolder
    curl -o actions-runner-linux-x64-2.330.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.330.0/actions-runner-linux-x64-2.330.0.tar.gz
    tar xzf ./actions-runner-linux-x64-2.330.0.tar.gz
    \$token = Read-Host 'Enter registration token for this runner'
    ./config.sh --url https://github.com/$Repo --token \$token --name $RunnerFolder
    ./run.sh & 
"@

    # Execute commands on EC2 via SSH
    ssh -i $KeyPath $User@$EC2IP $Commands
}
