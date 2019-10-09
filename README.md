<center> <h1>Palmyra</h1> </center>

## What is Palmyra?

Palmyra is a command line tool that validates your Localizable.strings files against inconsistent usage of string interpolations. It checks if strings for the same keys across different languages have the same set of interpolations (i.e. one `%@` and one `%d`). It will also give you warnings if there are any missing or redundant strings when compared to your reference file (most probably your develpoment language .strings file).

## Why use Palmyra?

People who translate your Localizable.strings files often don't have this specific knowledge about how string interpolations work in what are the valid formats. They're also, like all people, make people mistakes. They'll accidentally add space between `%` and `@` or add one where it shouldn't be. iOS runtime on the other hand is merciless and it will crash your app, when such mistke occurs. Palmyra has been created to save you from those mistakes.

## Installation

Currently the recommended way to install Palmyra is [Homebrew](https://brew.sh).

Once you make you have Homebrew installed on your computer, just do:
```
 $ brew tap appunite/formulae
 $ brew install palmyra
```

## Usage

To make Palmyra work, you'll need pass two parameters:
1. Path to your reference Localizable.strings file (your development language file) - `--reference` or `-r` for short
2. Paths to your translation files - `--translations` or `-t`

For example:
```
 $ palmyra -r Project/en.lproj/Localizable.strings -t Project/pl.lproj/Localizable.strings Project/de.lproj/Localizable.strings Project/es.lproj/Localizable.strings
```

## Contributing

Pull requests are welcome :)
