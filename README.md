Callan "Unistar" multibus machine

This is a multibus based computer based on a
Pacific Microsystems PM68K cpu board.

This project is about analyzing the bootroms and
augmenting them with the ability to support a
remote "stub" protocol.

-- Roms - read and disassemble boot roms
-- toS - C program to generate S records
-- Srecord - a tool to download S records
-- First - a first tiny test to download and run
-- libgcc - vital routines from libgcc in assembler
-- printf - set up a C development framework
-- ram - ram diagnostic
-- hd1 - first attempts at driver for the hard drive controller
-- cwc-firmware - analysis of firmware in the hard drive controller
-- hd2 - driver for the hard drive controller after I get good RAM card
-- uart - improved serial IO for interaction with python script
-- hd3 - hopefully the final hd driver and contents extraction

