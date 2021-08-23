#!/usr/bin/env bash

apple=`lsof | grep "AppleCamera"`

vdc=`lsof | grep "VDC"`

kill ${apple}
kill ${vdc}

sudo killall VDCAssistant; sudo killall AppleCameraAssistant
