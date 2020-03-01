
zlua-dir = $E:HOME/.elvish/lib/github.com/skywind3000/z.lua
zlua-path = $zlua-dir/z.lua

fn z [@args]{

  zlua~ = ( external $zlua-path )

  zlua $@args
}
