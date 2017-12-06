# byrthdays

## About
Command line tool for macOS to to list people with birthdays from your contacts.

## Install

### Homebrew
Comes next

### Manual installation
1. Go to [Releases](https://github.com/olfuerniss/byrthdays/releases) and download the latest release
2. Unzip and place the ```byrthdays``` binary in ```/usr/local/bin``` or any other folder that is in your path

## Usage
```
> byrthdays -h
```

```

Byrthdays is a tool to list people with birthdays from your macOS contacts.

Usage:
  byrthdays [-d <days>] [-o <pretty|json|xml|csv>] [-t <size>]

Options:
  -d  extract only birthdays within the given number of days (default 14; -1 for all)
  -o  to set the output format. Can be either 'pretty', 'json', 'xml' or 'csv' (default 'pretty')
  -t  to set the maximum thumbnail width/height of the contact images. It only prints the base64 encoded thumbnail data (PNG) when this option is used
  -h  prints this help

byrthdays v1.0.4
Oliver Fürniß, 06/12/2017
Website: https://github.com/olfuerniss/byrthdays

```

I use the JSON output in my byrthdays widget for [Übersicht](http://tracesof.net/uebersicht/)  (not released yet). Could also be used in [Alfred](https://www.alfredapp.com/) workflows or menu bar apps like [BitBar](https://getbitbar.com/).
