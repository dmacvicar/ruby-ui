#ifndef RUBY_NATIVE_UI_H
#define RUBY_NATIVE_UI_H

#include "ruby.h"

#define YUILogComponent "ruby-ui"
#include <yui/YUILog.h>

#include "widget_object_map.h"

extern "C" void __attribute__ ((visibility("default"))) Init_ui();

#endif
