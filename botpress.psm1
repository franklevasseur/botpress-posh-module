$BOT = "C:\\Users\\franc\\Documents-franc\\botpress-root"

function bot { 
    $script = "
        const cliSelect = require('cli-select')
        const fs = require('fs')
        const path = require('path')
        const bot = '$bot'
        const childDirs = fs.readdirSync(bot, { withFileTypes: true })
            .filter(dirent => dirent.isDirectory())
            .map(dirent => dirent.name)
            .filter(name => !name.startsWith('.'))
        cliSelect({ values: ['root', ...childDirs], outputStream: process.stderr }).then(x => {
                if (x.value === 'root') {
                    console.log(bot)
                    return
                }
                console.log(path.join(bot, x.value))
            }).catch(() => {
                console.log('.')
                return
            })
    "
    cd $(node -e $script)
 }

Function yb {
    Param ([string]$module)

    if (($module -eq 'core') -or ($module -eq 'studio') -or ($module -eq 'shared') -or ($module -eq 'admin')) {
        yarn cmd build:$module
    }
    elseif ($module -ne '') {
        yarn cmd build:modules --m $module
    }
    else {
        yarn build
    }
}

Function ys {
    Param ([string]$entry_point)

    if ($entry_point -eq 'l') {
        yarn start lang --dim=300
    }
    elseif ($entry_point -eq 'stan') {
        ys nlu --languageURL=http://localhost:3100 --ducklingURL=http://localhost:8000/ --modelCacheSize=1gb --body-size=900kb --silent
    }
    else {
        yarn start $entry_point $args
    }
}

Function yt {
    Param ([string]$test)
    yarn test $test $args
}

Function y {
    yarn $args
}


Function bpconf() {
    Param ([string]$filename)

    if (($filename -eq 'global') -or ($filename -eq '')) {
        Write-Output "${pwd}\out\bp\data\global\botpress.config.json"
    }
    elseif ( $filename -eq "posh" ) {
        Write-Output "${PSScriptRoot}\botpress.psm1"
    }
    else {
        Write-Output "${pwd}\out\bp\data\global\config\${filename}.json"
    }
}

Function bitf() {
    Param ([string]$command)

    if (($command -eq 'ls') -or ($command -eq 'list') -or ($command -eq '')) {
        node -e "require('@botpress/bitfan').default.datasets.listFiles().then(x => console.log(x))"
    }
    else {
        Write-Output "${command} is not a valid bitfan command."
    }
}

Function redis() {
    docker run -it --rm -p 6379:6379 --name docker-redis redis
}

Export-ModuleMember -Function bot, yb, ys, yt, y, bpconf, bitf, redis
Export-ModuleMember -Variable BOT