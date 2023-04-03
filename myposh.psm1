####################
### 0. Constants ###
####################

$myposh = "${PSScriptRoot}\\myposh.psm1"
$code="C:\\Users\\$env:UserName\\Documents\\code"

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

Function newdate() {
    Get-Date -Format "yyyy-MM-ddThh:mm:ss:msZ"
}

############################
### 2. Node / NPM / Yarn ###
############################

Function tsn { ts-node --transpile-only @args }

Function y { yarn @args }
Function yb { yarn build @args }
Function ys { yarn start @args }
Function yt { yarn test @args }
Function yp { yarn package @args }
Function yw { yarn workspace @args }

Function p { 
    if(!($args)) {
        pnpm i
    } else {
        pnpm @args
    }
}
Function pb { pnpm run build @args }
Function ps { pnpm run start @args }
Function pt { pnpm run test @args }
Function pp { pnpm run package @args }
Function pw { pnpm -r --stream --workspace-concurrency=1 @args }

#################
### 3. Python ###
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

###################
### 4. Services ###
###################

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

Function docker_postgres() {
    docker run -it --rm --name postgres -p 5432:5432 -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=postgres postgres 
}

##################
### 5. Exports ###
##################

Export-ModuleMember -Function yb, ys, yt, yp, yw, y, p, pb, ps, pt, pp, pw, docker_redis, docker_duck, docker_minio, touch, escapepath, dirname, newdate, tsn, venvco, mkvenv, rmvenv
Export-ModuleMember -Variable myposh, code
Export-ModuleMember -Alias source
