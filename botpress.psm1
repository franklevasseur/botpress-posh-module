#############################
### 0. Botpress Constants ###
#############################

$user = "francois"
$bot = "C:\\Users\\$user\\Documents\\botpress-root"
$bp_sql_uri = "postgres://postgres:postgres@localhost:5433/botpress"
$bp_cache = "C:\\Users\\$user\\botpress"
$bp_posh = "${PSScriptRoot}\\botpress.psm1"
$profile = "C:\Users\$user\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
$code="C:\\Users\\$user\\Documents\\code"

#############################
### 1. Basic Unix / Utils ###
#############################

Set-Alias -Name source -Value Import-Module
New-Alias which get-command

Function escapepath() {
    Param ([string]$path, [boolean]$forward=$false)
    if ( $forward ) {
        $full_file_path = ($path | Resolve-Path).path -replace '[\\/]', '/'
        Write-Output $full_file_path    
    } else {
        $full_file_path = ($path | Resolve-Path).path -replace '[\\/]', '\\'
        Write-Output $full_file_path
    }
}

Function touch() {
    Param ([string]$file_name)
    New-Item -ItemType file $file_name
}

Function dirname() {
    if(!($args)){
        Write-Output "arguments expected"
        return
    }
    Split-Path @args
}

Function cwd() {
    $curdir = $(pwd)
    $targetdir = $args[0]
    $arguments = $args | Select-Object -Skip 1
    $command = [system.String]::Join(" ", $arguments)
    
    try {
        cd $targetdir
        Invoke-Expression -Command $command
    } finally {
        cd $curdir
    }
}

Function newdate() {
    node -e "console.log(new Date())"
}

############################
### 2. Node / NPM / Yarn ###
############################

Function tsn { ts-node --transpile-only @args }
Function yb { yarn build @args }
Function ys { yarn start @args }
Function yt { yarn test @args }
Function y { yarn @args }
Function yp { yarn package @args }
Function yw { yarn workspace @args }

Function yv() {
    $raw = $(yarn -v)
    $nodejs_script = "
        const raw = '$raw'
        const [major, minor, patch] = raw.split('.')
        const majorNum = parseInt(major)
        if (majorNum > 1) { console.log('berry') }
        else if (majorNum === 1) { console.log('classic') }
    "
    node -e $nodejs_script
}

Function ywls() {
    $yarn_release = $(yv)

    if ($yarn_release -eq 'berry') {
        $raw = $((yarn workspaces list --json).Split('\n'))
        Foreach ($i in $raw)
        {
            (Write-Output $i | ConvertFrom-Json).Name
        }
        return
    }

    if ($yarn_release -eq 'classic') {
        Write-Output (yarn workspaces info | Select -Skip 1 | Select -SkipLast 1 | ConvertFrom-Json | Get-Member | Where-Object {$_.MemberType -eq 'NoteProperty'}).Name
        return
    }
}

############################
### 3. Botpress Services ###
############################

Function docker_redis() {
    docker run -it --rm -p 6379:6379 --name redis redis
}

Function docker_duck() {
    docker run -it --rm -p 8000:8000 --name duckling rasa/duckling
}

Function docker_minio() {
    param([Parameter(Mandatory=$true)][string]$datadir)
    docker run -it --rm -p 9000:9000 -p 9001:9001 --name minio minio/minio server $datadir --console-address ":9001"
}

Function bpsql() {
    param([Parameter(Mandatory=$false)][string]$query)
    if(!($query)){
        psql $bp_sql_uri
    } else {
        psql -c $query $bp_sql_uri
    }
}

#################
### 4. Others ###
#################

Function mkvenv() {
    Param ([string]$venvname='.venv')
    python -m venv $venvname
}

Function rmvenv() {
    Param ([string]$venvname='.venv')
    Remove-Item -Recurse -Force $venvname
}

# venv check out
Function venvco() {
    Param ([string]$venvname='.venv')
    source ".\\$venvname\\Scripts\\Activate.ps1"
}

##################
### 5. Exports ###
##################

Export-ModuleMember -Function yv, yb, ys, yt, yp, yw, y, ywls, docker_redis, docker_duck, docker_minio, bpsql, touch, escapepath, dirname, cwd, newdate, tsn, venvco, mkvenv, rmvenv
Export-ModuleMember -Variable bot, bp_sql_uri, bp_cache, bp_posh, code
Export-ModuleMember -Alias source
