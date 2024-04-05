// Copyright 2017 Square, Inc.

#pragma once

#include <cardreader_shared/crs_app_msg_hdr.h>

#define X_MSG_IN(X_MSG_NAME, X_A, X_B, X_C, X_D) X_MSG_NAME = CRS_APP_MAKE_MSG_TYPE((X_A), (X_B), (X_C), (X_D)),
#define X_MSG_OUT(X_MSG_NAME, X_A, X_B, X_C, X_D) X_MSG_NAME = CRS_APP_MAKE_MSG_TYPE((X_A), (X_B), (X_C), (X_D)),
enum {
#include <cardreader_shared/eps/modem.def>
#include <cardreader_shared/eps/syscfg.def>
#include <cardreader_shared/eps/power.def>
#include <cardreader_shared/eps/tamper.def>
#include <cardreader_shared/eps/keybag.def>
#include <cardreader_shared/eps/m1.def>
#include <cardreader_shared/eps/l1.def>
#include <cardreader_shared/eps/l2ctl.def>
#include <cardreader_shared/eps/l2io.def>
#include <cardreader_shared/eps/eventlog.def>
#include <cardreader_shared/eps/fwup.def>
#include <cardreader_shared/eps/coredump.def>
#include <cardreader_shared/eps/mfgtest.def>
#include <cardreader_shared/eps/securesession.def>
#include <cardreader_shared/eps/stats.def>
#include <cardreader_shared/eps/system.def>
#include <cardreader_shared/eps/stm.def>
#include <cardreader_shared/eps/squid_key_agree.def>
#include <cardreader_shared/eps/tmn.def>
#include <cardreader_shared/eps/tmnctl.def>
};
#undef X_MSG_IN
#undef X_MSG_OUT
