# Makefile for ODataBr
# Requires: Delphi command-line compiler (dcc32.exe)
#
# Usage:
#   make server      - Compile OData server
#   make clean       - Remove compiled artifacts

DCC32 ?= dcc32
BASE  ?= $(CURDIR)
DCU   ?= $(BASE)\dcu

# Unit search paths (-U)
UPATH  = $(BASE);$(BASE)\MVCBrServer;$(BASE)\MVCBrServer\WS
UPATH += $(BASE)\MVCBrServer\WSConfig;$(BASE)\MVCBrServer\Models
UPATH += $(BASE)\oData
UPATH += $(BASE)\DMVC\sources;$(BASE)\DMVC\lib\loggerpro
# Dependência externa: MVCBr framework (clone lado a lado)
UPATH += $(BASE)\..\MVCBr;$(BASE)\..\MVCBr\helpers
UFLAGS = -U"$(UPATH)" -I"$(UPATH)"
CFLAGS = -U"$(UPATH)" -I"$(UPATH)" -NO$(DCU) -LE$(DCU) -LN$(DCU)
CFLAGS += -NS"Data.Win;Datasnap.Win;Web.Win;Soap.Win;Xml.Win;Bde;Vcl;System;Xml;Data;Datasnap;Web;Soap;Winapi;Windows;System.Win;VCLTee"
CFLAGS += -AWinTypes=Windows;WinProcs=Windows;DbiTypes=BDE;DbiProcs=BDE;DbiErrs=BDE;

.PHONY: all server clean

all: server

server:
	$(DCC32) ODataBrServer.dpr $(CFLAGS)

clean:
	-del /s *.dcu 2>nul
	-del /s *.exe 2>nul
	-del /s *.map 2>nul
	-del /s *.drc 2>nul
	-del /s *.tds 2>nul
	-if exist $(DCU) rmdir /s /q $(DCU)
