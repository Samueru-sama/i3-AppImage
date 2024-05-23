# i3 window manager AppImage

Unofficial AppImage of i3: https://github.com/i3/i3

Works like the regular i3, once launched AppRun exports its `/usr/bin` directory to `$PATH` so that after i3 is started you can use `i3-msg` and others.

# HOW TO START? 

It is a simple as adding the appimage to your `$PATH` (and ideally renaming it to just `i3` without the .AppImage) and starting it from your shell. 

I have no idea how this could be started from lightdm or similar.

# PATCHED VERSION

The patched version contains this patch that fixes an issue that affects multi monitor users: https://github.com/i3/i3/pull/5521

The version is built from this fork where I merged that fix: https://github.com/Samueru-sama/i3

This appimage works without fuse2 as it can use fuse3 instead.
