{ config, pkgs, ... }:

{
    environment.systemPackages = [ pkgs.nano ];    
    environment.etc = {
    # Creates /etc/nanorc
        nanorc = {
            # The UNIX file mode bits
            mode = "0440";            
            text = ''
                ## Here is an example for nanorc files.
                syntax "Nanorc" "\.?nanorc$"
                comment "#"                

                ## Possible errors and parameters
                icolor brightred "^[[:space:]]*((un)?set|include|syntax|i?color).*$"
                ## Colors
                icolor black " black"
                icolor red " red"
                icolor green " green"
                icolor yellow " yellow"
                icolor blue " blue"
                icolor magenta " magenta"
                icolor cyan " cyan"
                icolor white " white"
                icolor normal " normal"
                icolor brightblack " brightblack"
                icolor brightred " brightred"
                icolor brightgreen " brightgreen"
                icolor brightyellow " brightyellow"
                icolor brightblue " brightblue"
                icolor brightmagenta " brightmagenta"
                icolor brightcyan " brightcyan"
                icolor brightwhite " brightwhite"
                icolor brightnormal " brightnormal"
                icolor ,black ",black "
                icolor ,red ",red "
                icolor ,green ",green "
                icolor ,yellow ",yellow "
                icolor ,blue ",blue "
                icolor ,magenta ",magenta "
                icolor ,cyan ",cyan "
                icolor ,white ",white "
                icolor ,normal ",normal"
                icolor magenta "^[[:space:]]*i?color\>" "\<(start|end)="
                icolor yellow "^[[:space:]]*(set|unset)[[:space:]]+(errorcolor|functioncolor|keycolor|numbercolor|selectedcolor|statuscolor|stripecolor|titlecolor)[[:space:]]+(bright)?(white|black|red|blue|green|yellow|magenta|cyan|normal)?(,(white|black|red|blue|green|yellow|magenta|cyan|normal))?\>"

                ## Keywords
                icolor brightgreen "^[[:space:]]*(set|unset)[[:space:]]+(afterends|allow_insecure_backup|atblanks|autoindent|backup|backupdir|boldtext|brackets|breaklonglines|casesensitive|constantshow|cutfromcursor|emptyline|errorcolor|fill|functioncolor|guidestripe|historylog|jumpyscrolling|keycolor|linenumbers|locking|matchbrackets|morespace|mouse|multibuffer|noconvert|nohelp|nonewlines|nopauses|nowrap|numbercolor|operatingdir|positionlog|preserve|punct|quickblank|quotestr|rawsequences|rebinddelete|regexp|selectedcolor|showcursor|smarthome|smooth|softwrap|speller|statuscolor|stripecolor|suspend|tabsize|tabstospaces|tempfile|titlecolor|trimblanks|unix|view|whitespace|wordbounds|wordchars|zap)\>"
                icolor green "^[[:space:]]*(bind|set|unset|syntax|header|include|magic)\>"
                ## Strings
                icolor white ""(\\.|[^"])*""
                ## Comments
                icolor brightblue "^[[:space:]]*#.*$"
                icolor cyan "^[[:space:]]*##.*$"

                ## Trailing whitespace
                icolor ,green "[[:space:]]+$"

                # git - TODO -> merge files together and separate from this nix config
                syntax "git-config" "git(config|modules)$|\.git/config$"

                color brightcyan "\<(true|false)\>"
                color cyan "^[[:space:]]*[^=]*="
                color brightmagenta "^[[:space:]]*\[.*\]$"
                color yellow ""(\\.|[^"])*"|'(\\.|[^'])*'"
                color brightblack "(^|[[:space:]])#([^{].*)?$"
                color ,green "[[:space:]]+$"
                color ,red "	+"

                # This code is free software; you can redistribute it and/or modify it under
                # the terms of the new BSD License.
                #
                # Copyright (c) 2010, Sebastian Staudt

                # A nano configuration file to enable syntax highlighting of some Git specific
                # files with the GNU nano text editor (http://www.nano-editor.org)
                #
                syntax "git-commit" "COMMIT_EDITMSG|TAG_EDITMSG"

                # Commit message
                color yellow ".*"

                # Comments
                color brightblack "^#.*"

                # Files changes
                color white       "#[[:space:]](deleted|modified|new file|renamed):[[:space:]].*"
                color red         "#[[:space:]]deleted:"
                color green       "#[[:space:]]modified:"
                color brightgreen "#[[:space:]]new file:"
                color brightblue  "#[[:space:]]renamed:"

                # Untracked filenames
                color black "^#	[^/?*:;{}\\]+\.[^/?*:;{}\\]+$"

                color brightmagenta "^#[[:space:]]Changes.*[:]"
                color brightred "^#[[:space:]]Your branch and '[^']+"
                color brightblack "^#[[:space:]]Your branch and '"
                color brightwhite "^#[[:space:]]On branch [^ ]+"
                color brightblack "^#[[:space:]]On branch"

                # Recolor hash symbols

                # Recolor hash symbols
                color brightblack "#"

                # Trailing spaces (+LINT is not ok, git uses tabs)
                color ,green "[[:space:]]+$"


                # This syntax format is used for interactive rebasing
                syntax "git-rebase-todo" "git-rebase-todo"

                # Default
                color yellow ".*"

                # Comments
                color brightblack "^#.*"

                # Rebase commands
                color green       "^(e|edit) [0-9a-f]{7,40}"
                color green       "^#  (e, edit)"
                color brightgreen "^(f|fixup) [0-9a-f]{7,40}"
                color brightgreen "^#  (f, fixup)"
                color brightwhite "^(p|pick) [0-9a-f]{7,40}"
                color brightwhite "^#  (p, pick)"
                color blue        "^(r|reword) [0-9a-f]{7,40}"
                color blue        "^#  (r, reword)"
                color brightred   "^(s|squash) [0-9a-f]{7,40}"
                color brightred   "^#  (s, squash)"
                color yellow      "^(x|exec) [^ ]+ [0-9a-f]{7,40}"
                color yellow      "^#  (x, exec)"

                # Recolor hash symbols
                color brightblack "#"

                # Commit IDs
                color brightblue "[0-9a-f]{7,40}"

                # general editing
                set indicator
                set linenumbers

                '';
                };
            };
}