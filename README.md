## Oculis Station 13 (/tg/station Downstream)

[![CI Suite](https://github.com/OculisStation/OculisStation/workflows/CI%20Suite/badge.svg)](https://github.com/OculisStation/OculisStation/actions?query=workflow%3A%22CI+Suite%22)
[![Percentage of issues still open](https://isitmaintained.com/badge/open/OculisStation/OculisStation.svg)](https://isitmaintained.com/project/OculisStation/OculisStation "Percentage of issues still open")
[![Average time to resolve an issue](https://isitmaintained.com/badge/resolution/OculisStation/OculisStation.svg)](https://isitmaintained.com/project/OculisStation/OculisStation "Average time to resolve an issue")
![Coverage](https://img.shields.io/codecov/c/github/OculisStation/OculisStation)

[![resentment](.github/images/badges/built-with-resentment.svg)](.github/images/comics/131-bug-free.png) [![technical debt](.github/images/badges/contains-technical-debt.svg)](.github/images/comics/106-tech-debt-modified.png) [![forinfinityandbyond](.github/images/badges/made-in-byond.gif)](https://www.reddit.com/r/SS13/comments/5oplxp/what_is_the_main_problem_with_byond_as_an_engine/dclbu1a)

| Website                  | Link                                                                                                                                   |
| ------------------------ | -------------------------------------------------------------------------------------------------------------------------------------- |
| How to Write a Design Doc| [https://hackmd.io/@tgstation/BkzmU9EyK](https://hackmd.io/@tgstation/BkzmU9EyK)                                                       |
| Git / GitHub cheatsheet  | [https://www.notion.so/Git-GitHub-61bc81766b2e4c7d9a346db3078ce833](https://www.notion.so/Git-GitHub-61bc81766b2e4c7d9a346db3078ce833) |
| Guide to Modularization  | [./modular_oculis/readme.md](./modular_oculis/readme.md)                                                                               |
| Guide to Mirroring       | [./modular_oculis/mirroring_guide.md](./modular_oculis/mirroring_guide.md)                                                             |
| Code                     | [https://github.com/OculisStation/OculisStation](https://github.com/OculisStation/OculisStation)                                         |
| Wiki                     | [https://oculis.miraheze.org/wiki/Main_Page](https://oculis.miraheze.org/wiki/Main_Page)                                               |
| Nova's Codedocs          | [https://NovaSector.github.io/NovaSector/](https://NovaSector.github.io/NovaSector/)                                                   |
| Oculis Station's Discord | [https://discord.gg/h77rMj2Eb8](https://discord.gg/h77rMj2Eb8)                                                                         |
| Coderbus Discord         | [https://discord.gg/Vh8TJp9](https://discord.gg/Vh8TJp9)                                                                               |

This is Oculis' [Iris' downstream](https://github.com/IrisSS13/IrisStation/) fork of [Nova Sector](https://github.com/NovaSector/NovaSector/), which in turn is a downstream fork of [/tg/station](https://github.com/tgstation/tgstation) created in BYOND.

There are NSFW sprites in the codebase, but all NSFW code has been removed. Sprites will be removed when possible. This is a SFW fork.

Space Station 13 is a paranoia-laden round-based roleplaying game set against the backdrop of a nonsensical, metal death trap masquerading as a space station, with charming spritework designed to represent the sci-fi setting and its dangerous undertones. Have fun, and survive!

## Important note - TEST YOUR PULL REQUESTS

You are responsible for the testing of your content and providing proof of such in your pull request. You should not mark a pull request ready for review until you have actually tested it. Test merges are not for bug finding, they are for stress tests where local testing simply doesn't allow for this.

## DEVELOPMENT

Please follow the modularisation guide, it makes it much easier for us to keep up to date with upstreams.

[Modularisation Guide](./modular_oculis/readme.md)

## DOWNLOADING

[Downloading](.github/guides/DOWNLOADING.md)

[Running on the server](.github/guides/RUNNING_A_SERVER.md)

[Maps and Away Missions](.github/guides/MAPS_AND_AWAY_MISSIONS.md)

## Compilation

Find `BUILD.bat` here in the root folder of tgstation, and double click it to initiate the build. It consists of multiple steps and might take around 1-5 minutes to compile.

**The long way**. Find `bin/build.cmd` in this folder, and double click it to initiate the build. It consists of multiple steps and might take around 1-5 minutes to compile. If it closes, it means it has finished its job. You can then [setup the server](.github/guides/RUNNING_A_SERVER.md) normally by opening `tgstation.dmb` in DreamDaemon.

**Building tgstation in DreamMaker directly is deprecated and might produce errors**, such as `'tgui.bundle.js': cannot find file`.

**[How to compile in VSCode and other build options](tools/build/README.md).**

## Getting started

For contribution guidelines refer to the
[Guides for Contributors](.github/CONTRIBUTING.md).

For getting started (dev env, compilation) see the HackMD document [here](https://hackmd.io/@tgstation/HJ8OdjNBc#tgstation-Development-Guide).

For overall design documentation see [HackMD](https://hackmd.io/@tgstation).

Oculis lore is currently under development and will be released on [wiki](https://oculis.miraheze.org/wiki/Lore).

## LICENSE

All code after [commit 333c566b88108de218d882840e61928a9b759d8f on 2014/12/31 at 4:38 PM PST](https://github.com/tgstation/tgstation/commit/333c566b88108de218d882840e61928a9b759d8f) is licensed under [GNU AGPL v3](https://www.gnu.org/licenses/agpl-3.0.html).

All code before [commit 333c566b88108de218d882840e61928a9b759d8f on 2014/12/31 at 4:38 PM PST](https://github.com/tgstation/tgstation/commit/333c566b88108de218d882840e61928a9b759d8f) is licensed under [GNU GPL v3](https://www.gnu.org/licenses/gpl-3.0.html).
(Including tools unless their readme specifies otherwise.)

See LICENSE and GPLv3.txt for more details.

The TGS DMAPI is licensed as a subproject under the MIT license.

See the footer of [code/\_\_DEFINES/tgs.dm](./code/__DEFINES/tgs.dm) and [code/modules/tgs/LICENSE](./code/modules/tgs/LICENSE) for the MIT license.

All assets including icons and sound are under a [Creative Commons 3.0 BY-SA license](https://creativecommons.org/licenses/by-sa/3.0/) unless otherwise indicated.
