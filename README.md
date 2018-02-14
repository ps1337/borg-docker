# A dockerized Borg server

This is basically just a merged version of these images:

`sebcworks/borgbackup-server` and `sebcworks/borgbackup-base`

The only change is that `borg` gets installed via the latest release from GitHub instead of using pip because otherwise with the missing native msgpack, performance is < 0.

Use `make build` and `make run` to start a dockerized borg instance. Please check the `Makefile` for things you have to configure.

All credits go to sebcworks :)
