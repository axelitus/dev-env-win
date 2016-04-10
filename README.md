# Development Environment for Windows

[![Author][ico-axelitus]][link-axelitus]
[![GitHub Profile][ico-axelitus-github]][link-axelitus-github]
[![Software License][ico-license]][link-license] 

Personal development environment scripts and files for Windows.
This package is shared AS-IS with no warranties. Some of the scripts may harm your system and render it useless, so use with care.

BY USING ANY OF THIS SCRIPTS YOU AGREE THAT YOU ARE THE ONLY RESPONSIBLE IN CASE OF SYSTEM CORRUPTION, I AM NOT BE HELD RESPONSIBLE FOR ANY HARM THIS MAY CAUSE. 

## Scripts and Files

To be done.

### setup-env.bat

This script setups the development environment based on a root path. This includes establishing various environment variables (user scope) and cleaning known colliding PATH entries (user and global scope).

This is useful for having multiple XAMPP installations that can coexist (some port configurations for Apache and MySQL needed) so PHP code can be tested on the same machine with several different versions:

[![PHP multiple versions][img-dev-env-php-versions]][img-dev-env-php-versions]

The default PHP version is configurable in `<dev_root>\bin\php.bat` and is set to PHP 7.0 at this moment.
[![PHP default version][img-dev-env-php-default]][img-dev-env-php-default]

This helps setting the debug engine for multiple PHP versions in IDEs like [JetBrains' PhpStorm][link-phpstorm].

#### Usage

The usage is straight forward. Just open an elevated command prompt (needed to modify the System PATH variable) or run the script directly (as administrator).
The command accepts just one option:

```
C:\> setup-env <dev_root> <php_ver>
```

- `<dev_root>` The development root path.
- `<php_ver>` The default PHP version.

#### Requirements

Several requirements must be met in order for this to work correctly:

- The script must be run with administrative privileges to modify the system PATH variable.
- XAMPP versions must be installed into `<dev_root>\xampp` folder and each version should in turn be inside a folder with the version number (e.g. `<dev_root>\xampp\7.0`). _At the moment this is not configurable._

_**Notes:** At the moment all XAMPP/PHP versions are configured. If you wish some of them not to be configured you should dive into the script and `REM` (comment) those lines out._

#### What does it do?

The command will create the following environment variables, paths, and files.

##### Environment Variables

_**Note:** None of the paths contain a trailing slash._
 
- `DEV` The selected `<dev_root>` path.
- `DEV_BIN` The `%DEV%\bin` path for scripts and executables.
- `PHP` The path to the PHP selector script `%DEV_BIN%\php.bat`.
- `PHP_VER` The default PHP version for the PHP selector script.
- `PHP5_5` The path to the XAMPP 5.5 PHP folder `%XAMPP5_5%\php`.
- `PHP5_5_EXE` The path to the XAMPP 5.5 PHP executable `%PHP5_5%\php.exe`.
- `PHP5_5_XDBG` The path to the XAMPP 5.5 PHP xdebug extension `%PHP5_5%\ext\php_xdebug.dll`.
- `PHP5_6` The path to the XAMPP 5.6 PHP folder `%XAMPP5_6%\php`.
- `PHP5_6_EXE` The path to the XAMPP 5.6 PHP executable `%PHP5_6%\php.exe`.
- `PHP5_6_XDBG` The path to the XAMPP 5.6 PHP xdebug extension `%PHP5_6%\ext\php_xdebug.dll`.
- `PHP7_0` The path to the XAMPP 7.0 PHP folder `%XAMPP7_0%\php`.
- `PHP7_0_EXE` The path to the XAMPP 7.0 PHP executable `%PHP7_0%\php.exe`.
- `PHP7_0_XDBG` The path to the XAMPP 7.0 PHP xdebug extension `%PHP7_0%\ext\php_xdebug.dll`.
- `XAMPP` The path to the XAMPP folder `%DEV%\xampp`.
- `XAMPP` The path to the XAMPP 5.5 folder `%XAMPP%\5.5`.
- `XAMPP` The path to the XAMPP 5.6 folder `%XAMPP%\5.6`.
- `XAMPP` The path to the XAMPP 7.0 folder `%XAMPP%\7.0`.

##### Paths

- `<dev_root>\bin` This path contains executable scripts and is added to the user's PATH environment variable so that the scripts are always available. 

##### Files

- `<dev_root>\bin\php.bat` The PHP selector script.
- `<dev_root>\bin\php5.5.bat` The PHP 5.5 caller.
- `<dev_root>\bin\php5.5dbg.bat` The PHP 5.5 with debug caller.
- `<dev_root>\bin\php5.6.bat` The PHP 5.6 caller.
- `<dev_root>\bin\php5.6dbg.bat` The PHP 5.6 with debug caller.
- `<dev_root>\bin\php7.0.bat` The PHP 7.0 caller.
- `<dev_root>\bin\php7.0dbg.bat` The PHP 7.0 with debug caller.

## Contribution

This is a personal project but if you find something useful and you want to contribute please feel free to fork the project and send a pull request.

[ico-axelitus]: https://img.shields.io/badge/Author-Axel%20Pardemann-blue.svg?style=flat-square
[ico-axelitus-github]: https://img.shields.io/badge/GitHub-axelitus-blue.svg?style=flat-square
[ico-license]: https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square

[img-dev-env-php-default]: img/dev-env-php-default.png
[img-dev-env-php-versions]: img/dev-env-php-versions.png

[link-axelitus]: http://axelitus.mx
[link-axelitus-github]: https://github.com/axelitus
[link-license]: LICENSE.md
[link-phpstorm]: https://www.jetbrains.com/phpstorm/