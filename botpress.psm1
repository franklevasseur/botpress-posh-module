$bot = "C:\Users\franc\Documents-franc\botpress-root"

function bot{cd $bot}

Function yb {
    Param ([string]$module)

    if ($module -eq 'core' || $module -eq 'studio' || $module -eq 'shared' || $module -eq 'admin') {
        yarn cmd build:$module
    } elseif ($module -ne '') {
        yarn cmd build:modules --m $module
    } else {
        yarn build
    }
}

Function ys {
    Param ([string]$entry_point)

    if ($entry_point -eq 'l') {
        yarn start lang --dim=300
    } else {
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
	
    if ( $filename -eq "global" || $args.Count -eq 0 ) {
		echo "$(pwd)\out\bp\data\global\botpress.config.json"
	} elseif ( $filename -eq "posh" )
    {
		echo "${PSScriptRoot}\botpress.psm1"
	} else {
        echo "$(pwd)\out\bp\data\global\config\${filename}.json"
	}
}
