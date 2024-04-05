// Copyright 2019 Square, Inc.

#pragma once

#include <payment_platform_api.h>

void payment_init(const payment_platform_api_t* api);
void payment_reset(void);
void payment_process_msg(void* msg);
