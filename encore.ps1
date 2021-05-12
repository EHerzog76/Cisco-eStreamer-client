param([string]$1)

$PSep=[IO.Path]::DirectorySeparatorChar
$AppHOME= "C:\Progs\eStreamerClient3"
$proid='-1'
$pybin="python.exe"
$basepath="$($AppHOME)$($PSep)"
$configFilepath="$($basepath)estreamer.conf"
$basepathExists= Test-Path $basepath
$isRunning=0

# constants
$configure="$($basepath)estreamer$($PSep)configure.py $configFilepath"
$diagnostics="$($basepath)estreamer$($PSep)diagnostics.py $configFilepath"
$service="$($basepath)estreamer$($PSep)service.py $configFilepath"
$preflight="$($basepath)estreamer$($PSep)preflight.py $configFilepath"
$pidFile="encore.pid"

$EXIT_CODE_ERROR=0

function execprog {
    [CmdletBinding(SupportsShouldProcess)]
    param
        (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$FilePath,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$ArgumentList,

        [ValidateSet("Full","ExitCode","None")]
        [string]$DisplayLevel = "Full"
    )

    #$ErrorActionPreference = 'Stop'

    try {
        $pinfo = New-Object System.Diagnostics.ProcessStartInfo
        $pinfo.FileName = $FilePath
        $pinfo.RedirectStandardError = $false
        $pinfo.RedirectStandardOutput = $false
        $pinfo.UseShellExecute = $true
        $pinfo.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Normal  #'Hidden'
        #$pinfo.CreateNoWindow = $true
        $pinfo.Arguments = $ArgumentList
        $p = New-Object System.Diagnostics.Process
        $p.StartInfo = $pinfo
        $p.Start() | Out-Null
        $result = [pscustomobject]@{
        Title = ($MyInvocation.MyCommand).Name
        Command = $FilePath
        Arguments = $ArgumentList
        ExitCode = $p.ExitCode
        }
        $p.WaitForExit()

        if (-not([string]::IsNullOrEmpty($DisplayLevel))) {
            switch($DisplayLevel) {
                "Full" { return $result; break }
                "ExitCode" { return $result.ExitCode; break }
                }
            }
        }
    catch {
        Write-Host $_
        $result = [pscustomobject]@{
            Title = ($MyInvocation.MyCommand).Name
            Command = $FilePath
            Arguments = $ArgumentList
            ExitCode = 255
        }
        return
    }
}

function execprogHidden {
    [CmdletBinding(SupportsShouldProcess)]
    param
        (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$FilePath,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$ArgumentList,

        [ValidateSet("Full","StdOut","StdErr","ExitCode","None")]
        [string]$DisplayLevel = "Full"
    )

    #$ErrorActionPreference = 'Stop'

    try {
        $pinfo = New-Object System.Diagnostics.ProcessStartInfo
        $pinfo.FileName = $FilePath
        $pinfo.RedirectStandardError = $true
        $pinfo.RedirectStandardOutput = $true
        $pinfo.UseShellExecute = $false
        #$pinfo.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Normal  #'Hidden'
        #$pinfo.CreateNoWindow = $true
        $pinfo.Arguments = $ArgumentList
        $p = New-Object System.Diagnostics.Process
        $p.StartInfo = $pinfo
        $p.Start() | Out-Null
        $result = [pscustomobject]@{
        Title = ($MyInvocation.MyCommand).Name
        Command = $FilePath
        Arguments = $ArgumentList
        StdOut = $p.StandardOutput.ReadToEnd()
        StdErr = $p.StandardError.ReadToEnd()
        ExitCode = $p.ExitCode
        }
        $p.WaitForExit()

        if (-not([string]::IsNullOrEmpty($DisplayLevel))) {
            switch($DisplayLevel) {
                "Full" { return $result; break }
                "StdOut" { return $result.StdOut; break }
                "StdErr" { return $result.StdErr; break }
                "ExitCode" { return $result.ExitCode; break }
                }
            }
        }
    catch {
        Write-Host $_
        $result = [pscustomobject]@{
            Title = ($MyInvocation.MyCommand).Name
            Command = $FilePath
            Arguments = $ArgumentList
            StdOut = ""
            StdErr = $_
            ExitCode = 255
        }
        return
    }
}

function init() 
{ 
    # change pwd
    if ( $basepathExists -eq $True ) 
        { cd $basepath }
    
    else {
        echo "\"$basepath\" does not exist"
        exit $EXIT_CODE_ERROR
          }

    if ( ! ( Test-Path "$configFilepath" ) )
        { cp default.conf $configFilepath }
}

function setup() {
    Start-Process -FilePath $pybin -Wait -WindowStyle Normal -ArgumentList "$configure --enabled=true"
    Write-Host "Would you like to output to (1) Splunk, (2) CEF or (3) JSON?"
	$input = [System.Console]::ReadKey()

	if ( "$input" -eq "1" )
    {
        Start-Process -FilePath $pybin -Wait -WindowStyle Normal -ArgumentList "$configure --output=splunk"

        echo 'If you wish to change where data is written to then edit estreamer.conf '
        echo 'and change $.handler.outputters[0].stream.uri'
        echo

    } elseif ( "$input" -eq "2" )
    {
        Start-Process -FilePath $pybin -Wait -WindowStyle Normal -ArgumentList "$configure --output=cef"

        echo 'You need to set the target syslog server and port; edit estreamer.conf '
        echo 'and change $.handler.outputters[0].stream.uri'
        echo

    } elseif ( "$input" -eq "3" )
    {
        Start-Process -FilePath $pybin -Wait -WindowStyle Normal -ArgumentList "$configure --output=json"

        echo 'If you wish to change where data is written to then edit estreamer.conf '
        echo 'and change $.handler.outputters[0].stream.uri'
        echo

    } else {
        echo 'No changes made'
        echo
        exit $EXIT_CODE_ERROR
    }
}

function preflight()
{
    Start-Process -FilePath $pybin -Wait -WindowStyle Normal -ArgumentList "$preflight"
	#execprogHidden
    $ok=$?
    if ( $ok -eq $False )
    {
        exit $EXIT_CODE_ERROR
    }
	
	Start-Process -FilePath $pybin -Wait -WindowStyle Normal -ArgumentList "$configure --print pidFile" -RedirectStandardOutput $pidFile
	Start-Process -FilePath $pybin -Wait -WindowStyle Normal -ArgumentList "$configure --print pid" -RedirectStandardOutput $proid

    # Work out if we're running already
    (Get-Process | Where-Object { $_.Name -eq $configFilepath }).Count -gt 0
    $process = $?

    if ($proid -eq '-1')
    {
        #echo "Checking pid... none found."
    }
    if ($process -eq $False)
    {
        rm $pidFile
        $proid = -1
    }
    Elseif ($process -eq $True)
    {
        $isRunning=1
    }

}
function diagnostics()
{
	#[string]$strOut = ""
    #Start-Process -FilePath $pybin -Wait -WindowStyle Normal -ArgumentList "$($diagnostics)" -RedirectStandardOutput $strOut
	#Write-Host $strOut
	execprog -FilePath $pybin -ArgumentList $diagnostics
    #ready
}

function foreground()
{
    #Start-Process -FilePath $pybin -Wait -WindowStyle Normal -ArgumentList "$($service)"
	execprog -FilePath $pybin -ArgumentList $service
    #ready
}

function stop() 
{
    $isRunning = (Get-Process | Where-Object { $_.Name -eq $configFilepath }).Count -gt 0
    if ( $isRunning -eq $false )
    {
        echo "eNcore is not running"
    }
    else
    {
        echo "eNcore found pid. Terminating '$service' " 
        Stop-Process -processname $configFilepath

        while ( $True )
        {
            (Get-Process | Where-Object { $_.Name -eq $configFilepath }).Count -gt 0
            $process = $?
            
            if ( $process -eq $False)
            {
                break
            }

            sleep -s 0.5
        }
        $proid = -1
        sleep -s 1 
    }
}

function status()
{
    Start-Process -FilePath $pybin -Wait -WindowStyle Normal -ArgumentList "$configure --print splunkstatus"
}

function clean()
{
    ### Delete data older than 12 hours -> 720mins
    #find ../../data -type f -mmin +720 -delete
}
function main($1){
    
    switch ($1)
    {
        test 
        {init; preflight; diagnostics}
        start
        {init; preflight; foreground}
		foreground
		{init; foreground}
        stop
        {init; preflight; stop}
        status
        {init; status}
		setup
        {init; setup}
        clean
        {init; clean}
        default
        {   
            echo "Usage:  { start | stop | foreground | test | setup | status | clean }"
            echo "`n"
            echo '    start:      starts eNcore as a background task'
            echo '    stop:       stop the eNcore background task'
            echo '    restart:    stop the eNcore background task'
            echo '    foreground: runs eNcore in the foreground'
            echo '    test:       runs a quick test to check connectivity'
            echo '    status:     returns the current status'
			echo '    setup:      change the output (splunk | cef | json)'
            echo '    clean:      removes data older than 12 hours'
            echo "`n"
            echo "`t$1"
            exit $EXIT_CODE_ERROR 
          }
    }
    
}

main $1