
zlua-dir = $E:HOME/.elvish/lib/github.com/skywind3000/z.lua
zlua-path = $zlua-dir/z.lua
zlua-cd~ = [dest]{ builtin:cd $dest }
zlua-echo = $false

fn z [@args]{

  zlua~ = ( external $zlua-path )

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

  zdest = (zlua --cd $arg_type $arg_subdir $arg_inter $@args_rest)
  if (and (not-eq $zdest "") ?(test -d $zdest)) {
    zlua-cd $zdest
    if $zlua-echo { pwd }
  }
}

fn setup {

  zlua~ = ( external $zlua-path )

  fn add-before-readline [@hooks]{
    each [hook]{
      if (not (has-value $edit:before-readline $hook)) {
        edit:before-readline=[ $@edit:before-readline $hook ]
      }
    } $hooks
  }

  add-before-readline {
    zlua --add $pwd
  }

}
