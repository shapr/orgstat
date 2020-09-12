
# orgstat

[![Build Status](https://travis-ci.org/volhovm/orgstat.svg?branch=master)](https://travis-ci.org/volhovM/orgstat)
[![Hackage status](https://img.shields.io/hackage/v/orgstat.svg)](http://hackage.haskell.org/package/orgstat)

Orgstat is a statistics visualizer tool for org-mode. Given a set of org-mode files (gpg supported),
it parses AST, applies modifications such as tag filtering, pruning or selecting a subtree (which yields a _report_) and generates _output_ using specified params. Currently supported output types are:
* Timeline output: that's a svg image describing what took your time on every day of selected report range.
* Summary output: you specify the template string with `%reportName%` in it and it replaces each such occurrence with total hours spent on report. Useful for putting this info into your status bar.
* Script output: a generalisation of the summary output. Selected reports' durations are set as ENV variables and then the user's script is run in this new environment.
* Block output: that's what you'd expect from the default org report generator, though formatting is more similar to one that `tree` unix utility provides.

## Building/installing

`orgstat` uses haskell build tool [stack](https://docs.haskellstack.org/en/stable/README/). In order to build the project, run `stack build` in the project directory.

Since `orgstat` is also available on hackage, you can use `cabal install orgstat` to get it. If you're using `nix` package manager you can find `orgstat` in `nixpkgs` as `haskellPackages.orgstat` since `nixpkgs` has effectively everything available on hackage directly.

To install `orgstat` with `nix`:
```
nix-env -f "<nixpkgs>" -iA haskellPackages.orgstat
```

## Running

Check out [orgstatExample.yaml](./orgstatExample.yaml) sample configuration file (config is used to parametrize report) and `orgstat --help`:
```
$> orgstat --help
----- OrgStat ------

Usage: orgstat [--version] [--help] [--conf-path FILEPATH] [--debug]
               [--xdg-open] [--output|--select-output ARG]
               [--output-dir FILEPATH]
  Statistic reports visualizer for org-mode

Available options:
  --version                Show version
  --help                   Show this help text
  --conf-path FILEPATH     Path to the configuration file
  --debug                  Enable debug logging
  --xdg-open               Open each report using xdg-open
  --output,--select-output ARG
                           Output name(s) you want to process (default: all
                           outputs are processed)
  --output-dir FILEPATH    Final output directory that overrides one in config.
                           No extra subdirectories will be created

```
## Examples

See the [orgstatExample.yaml](./orgstatExample.yaml) configuration file.

Here how timeline report output looks like:
![Orgstat timeline report example](https://raw.githubusercontent.com/volhovM/orgstat/master/example.png)

That's how i use `summary` to put things into `xmobar`:
```
# all these reports are defined with range: week and single filterbytag modifier with appropriate tag
- name: curWeekStats
  type: summary
  template: "%thisWeekWork%/%thisWeekStudy% %thisWeekA1%/%thisWeekA2%/%thisWeekA3% %thisWeekI%/%thisWeekE%"
```

Then you run `stack exec orgstat -- --select-output resolveOutput --output-dir ~/` and it puts report into `~/curWeekStats.txt` yielding `0:57/0:09 2:03/2:48/3:16 1:57/2:34` inside. Add a bit of cron and xmobar task to read the text out of this file. That's it.

## Bugs and issues

If you experience any problems with the application, you can use `block` output and `--debug` to debug yourself (or you can just create an issue).
