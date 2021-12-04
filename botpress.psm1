$BOT = "C:\\Users\\franc\\Documents-franc\\botpress-root"
$bp_sql_uri = "postgres://postgres:postgres@localhost:5432/botpress"
$bp_cache = "C:\Users\franc\botpress"
$bp_posh = "${PSScriptRoot}\botpress.psm1"

Function escapepath() {
    Param ([string]$path, [boolean]$forward=$false)
    if ( $forward ) {
        $full_file_path = ($path | Resolve-Path).path -replace '[\\/]', '/'
        echo $full_file_path    
    } else {
        $full_file_path = ($path | Resolve-Path).path -replace '[\\/]', '\\'
        echo $full_file_path
    }
}

Function yb {
    yarn build $args
}

Function ys {
    yarn start $args
}

Function yt {
    yarn test $args
}

Function y {
    yarn $args
}

Function yp {
    yarn package $args
}

Function yw {
    yarn workspace $args
}

Function touch() {
    Param ([string]$file_name)
    New-Item -ItemType file $file_name
}

Function redis() {
    docker run -it --rm -p 6379:6379 --name redis redis
}

Function duck() {
    docker run -it --rm -p 8000:8000 --name duckling rasa/duckling
}

Function bpsql() {
    psql $bp_sql_uri
}

Function dirname() {
    Split-Path $args
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

Export-ModuleMember -Function yb, ys, yt, yp, yw, y, redis, duck, bpsql, touch, escapepath, dirname, cwd
Export-ModuleMember -Variable BOT, bp_sql_uri, bp_cache, bp_posh
