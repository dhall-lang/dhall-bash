# `dhall-bash 1.0.5`

This `dhall-bash` package provides a Dhall to Bash compiler so that you can
easily marshall Dhall values into your Bash scripts

This does not compile all available Dhall language constructs into Bash and
only supports extracting primitive values, lists, optional values and records
from normalized expressions.

## Quick start

If you have Nix installed, then you can build and install this package using:

```bash
$ nix-env -iA dhall-bash -f release.nix
$ dhall-to-bash <<< '1'
1
$ dhall-to-bash <<< '"ABC" ++ "DEF"'
ABCDEF
$ dhall-to-bash --declare FOO <<< '"ABC" ++ "DEF"'
declare -r FOO=ABCDEF
$ eval $(dhall-to-bash --declare FOO <<< '"ABC" ++ "DEF"')
$ echo "${FOO}"
ABCDEF
$ dhall-to-bash --declare BAR
let replicate = https://ipfs.io/ipfs/QmcTbCdS21pCxXysTzEiucDuwwLWbLUWNSKwkJVfwpy2zK/Prelude/List/replicate
in  replicate +10 Integer 1
<Ctrl-D>
declare -r -a BAR=(1 1 1 1 1 1 1 1 1 1)
$ dhall-to-bash --declare BAZ <<< '{ qux = 1, xyzzy = True }'
declare -r -A BAZ=([qux]=1 [xyzzy]=true)
```

## Development status

[![Build Status](https://travis-ci.org/Gabriel439/Haskell-Dhall-Bash-Library.png)](https://travis-ci.org/Gabriel439/Haskell-Dhall-Bash-Library)

I don't expect this library to change unless:

* ... the Dhall language changes, which is possible but not very likely
* ... there are bugs, which is unlikely given how simple the implementation is

## License (BSD 3-clause)

    Copyright (c) 2017 Gabriel Gonzalez
    All rights reserved.
    
    Redistribution and use in source and binary forms, with or without modification,
    are permitted provided that the following conditions are met:
        * Redistributions of source code must retain the above copyright notice,
          this list of conditions and the following disclaimer.
        * Redistributions in binary form must reproduce the above copyright notice,
          this list of conditions and the following disclaimer in the documentation
          and/or other materials provided with the distribution.
        * Neither the name of Gabriel Gonzalez nor the names of other contributors
          may be used to endorse or promote products derived from this software
          without specific prior written permission.
    
    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
    ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
    WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
    DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
    ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
    (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
    ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
    (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
    SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
