
zlua-dir = $E:HOME/.elvish/lib/github.com/skywind3000/z.lua
zlua-path = $zlua-dir/z.lua
zlua-cd~ = [dest]{ builtin:cd $dest }
zlua-echo = $false
zlua-enhanced = $true

fn zlua [@args]{
  if $zlua-enhanced {
    E:_ZL_MATCH_MODE=1 ( external $zlua-path ) $@args
  } else {
    ( external $zlua-path ) $@args
  }
}

fn z [@args]{

  if (eq $args []) {
    zlua -l
    return
  }

  h @tail = $@args

  if (eq $h "--add") {
    E:_ZL_RANDOM=( randint 0 32767 ) zlua --add $@tail
    return
  }

  if (eq $h "--complete") {
    zlua --complete $@tail
    return
  }

  arg_mode   = ""
  arg_type   = ""
  arg_subdir = ""
  arg_inter  = ""
  arg_strip  = ""
  args_rest = []

  for a $args {
        if (    eq $a -l) {        arg_mode="-l"
    } elif (    eq $a -e) {        arg_mode="-e"
    } elif (    eq $a -x) {        arg_mode="-x"
    } elif (    eq $a -t) {        arg_type="-t"
    } elif (    eq $a -r) {        arg_type="-r"
    } elif (    eq $a -c) {        arg_subdir="-c"
    } elif (    eq $a -s) {        arg_strip="-s"
    } elif (    eq $a -i) {        arg_inter="-i"
    } elif (    eq $a -I) {        arg_inter="-I"
    } elif (    eq $a --purge) {   arg_mode="--purge"
    } elif (or (eq $a -h) \
             (eq $a --help) ) {    arg_mode="-h"
    } else { args_rest = [$a $@args_rest] }
  }

  if (has-value [-h --purge] $arg_mode) {
    zlua $arg_mode
    return
  }

  if (or (eq $arg_mode -l) (eq $args_rest []) ) {
    zlua -l $arg_subdir $arg_type $arg_strip $@args_rest
    return
  }

  if (not-eq $arg_mode "") {
    zlua $arg_mode $arg_subdir $arg_type $arg_inter $@args_rest
    return
  }

  zdest = [(zlua --cd $arg_type $arg_subdir $arg_inter $@args_rest)]
  if (eq $zdest []) {
    fail "No destination folder could be found"
  } elif ?(test -d $zdest[0]) {
    zlua-cd $zdest[0]
    if $zlua-echo { pwd }
  }
}

fn setup [&once=false]{

  fn add-before-readline [@hooks]{
    each [hook]{
      if (not (has-value $edit:before-readline $hook)) {
        edit:before-readline=[ $@edit:before-readline $hook ]
      }
    } $hooks
  }

  fn add-after-chdir [@hooks]{
    each [hook]{
      if (not (has-value $builtin:after-chdir $hook)) {
        builtin:after-chdir=[ $@builtin:after-chdir $hook ]
      }
    } $hooks
  }

  if $once {
    add-after-chdir [dir]{
      zlua --add $pwd
    }
  } else {
    add-before-readline {
      zlua --add $pwd
    }
  }

}
