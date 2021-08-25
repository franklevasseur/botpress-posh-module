$BOT = "C:\\Users\\franc\\Documents-franc\\botpress-root"
$bp_sql_uri = "postgres://postgres:postgres@localhost:5432/botpress"
$bp_cache = "C:\Users\franc\botpress"
$bp_posh = "${PSScriptRoot}\botpress.psm1"

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

Function efs() {
    Param ([string]$command, [string]$file)

    $full_file_path = ($file | Resolve-Path).path -replace '[\\/]', '\\'

    $script = "
        const Prompt = require('prompt-password');
        const crypto = require('crypto');
        const fs = require('fs');
        const path = require('path')
        const PWD_CHAR = '*';
        const ALGORITHM = 'aes-192-cbc';
        const SALT = 'salt';

        const command = '$command'
        const file = path.resolve('$full_file_path')

        const getPwd = () => {
          return new Prompt({
            type: 'password',
            message: 'Enter your password please',
            name: 'password',
            mask: (input) => PWD_CHAR + new Array(String(input).length).join(PWD_CHAR),
          }).run();
        };
        const createKeyIv = (pwd) => {
          const key = crypto.scryptSync(pwd, SALT, 24);
          const iv = new Uint8Array(16);
          return { key, iv };
        };
        const encrypt = (str, pwd) => {
          const { key, iv } = createKeyIv(pwd);
          const cipher = crypto.createCipheriv(ALGORITHM, key, iv);
          return cipher.update(str, 'utf8', 'hex') + cipher.final('hex');
        };
        const decrypt = (str, pwd) => {
          const { key, iv } = createKeyIv(pwd);
          const decipher = crypto.createDecipheriv(ALGORITHM, key, iv);
          return decipher.update(str, 'hex', 'utf8') + decipher.final('utf8');
        };

        getPwd().then(pwd => {
            if (command === 'cat') {
                try {
                    const fileContent = fs.readFileSync(file, 'utf8');
                    const decrypted = decrypt(fileContent, pwd);
                    console.log(decrypted);
                    return
                } catch(err) { throw new Error('Invalid password') }
            }
            if (command === 'encrypt') {
                const fileContent = fs.readFileSync(file);
                const encrypted = encrypt(fileContent, pwd);
                fs.writeFileSync(file, encrypted);
                return
            }
            if (command === 'decrypt') {
                try {
                    const fileContent = fs.readFileSync(file, 'utf8');
                    const decrypted = decrypt(fileContent, pwd);
                    fs.writeFileSync(file, decrypted);
                    return
                } catch(err) { throw new Error('Invalid password') }
            }
            throw new Error('Invalid command')
        }).catch(err => console.error(err))
    "
    node -e $script
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

Function bpconf() {
    Param ([string]$filename)

    if ( $filename -eq "posh" ) {
        Write-Output $bp_posh
        return
    }

    Write-Output "No config for $filename"
}

Function touch() {
    Param ([string]$file_name)
    New-Item -ItemType file $file_name
}

Function redis() {
    docker run -it --rm -p 6379:6379 --name docker-redis redis
}

Function bpsql() {
    psql $bp_sql_uri
}

Export-ModuleMember -Function bot, yb, ys, yt, y, bpconf, bitf, redis, bpsql, touch, efs
Export-ModuleMember -Variable BOT, bp_sql_uri, bp_cache, $bp_posh