#!/bin/sh
# The backslash makes the next line a comment in Tcl \
exec tclsh "$0" ${1+"$@"}

# Copyright @ Ye XIA <qazxiaye@126.com>

proc ColorPrint {str fg {nonewline 0}} {
    set fgList "30 black 31 red 32 green 33 yellow 34 blue 37 white"
    set fgNo   [lindex $fgList [expr [lsearch $fgList $fg] - 1]]
    set str    "\033\[0;${fgNo}m$str\033\[0m"
    if {$nonewline != 1} {
        puts "$str"
    } else {
        puts -nonewline "$str"
    }
}

proc Usage {} {
    ColorPrint "Usage :" green
    puts ""
    ColorPrint "addDeclare.tcl -" green 1
    ColorPrint "lang path_to_src_folder" yellow
    puts ""
    ColorPrint "lang options : java, c, cpp, tcl, r, py" green
}

if {$argc != 2} {
    Usage
    return
}

#parse argv
set lang ""
set path ""

regexp {^\-(\w+)\ (.+)$} $argv vv lang path

if {$lang eq "" || $path eq ""} {
    Usage
    return
}

#get declaration content
set scriptPath [file dirname [file normalize $argv0]]
catch {exec cat $scriptPath/declare/$lang} declaration

#get src files
catch {exec find $path -name *.$lang} srcFiles

set tmp [clock seconds]
proc InsertDeclare {srcFile from} {
    global declaration tmp

    set outFile [open $srcFile.$tmp w]

    set count 0
    set inFile [open $srcFile r]
    while {![eof $inFile]} {
        if {$count == $from} {
            if {$count != 0} {
                puts $outFile ""
            }
            puts $outFile $declaration
        }

        gets $inFile line
        puts $outFile $line

        incr count
    }

    close $inFile
    close $outFile

    exec mv $srcFile.$tmp $srcFile
    ColorPrint "$srcFile added." green
}

switch -regexp -- $lang {
    ^(java|c|cpp)$ {
        foreach f $srcFiles {
            InsertDeclare $f 0
        }
    }

    ^(py|r)$ {
        foreach f $srcFiles {
            catch {exec head $f -n 1} line

            if {[regexp {^\#\!} $line]} {
                InsertDeclare $f 1
            } else {
                InsertDeclare $f 0
            }
        }
    }

    ^tcl$ {
        foreach f $srcFiles {
            catch {exec head $f -n 1} line

            if {[regexp {^\#\!.+tcl} $line]} {
                InsertDeclare $f 1
            } elseif {[regexp {^\#\!} $line]} {
                InsertDeclare $f 3
            } else {
                InsertDeclare $f 0
            }
        }
    }

    default {
        ColorPrint "Sorry, input extention $lang is not supported yet." red
    }
}

