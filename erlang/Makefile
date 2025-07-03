PROJECT = erlang
PROJECT_DESCRIPTION = New project
PROJECT_VERSION = 0.1.0

DEPS = cowboy eredis
dep_cowboy = 2.13.0
dep_eredis = 1.2.0

REL_DEPS += relx
DEP_PLUGINS = cowboy

# Erlang LS configuration
ERL_LS_DEPS = erlang_ls
dep_erlang_ls = 0.47.0

include erlang.mk

# Add Erlang LS to the shell profile
shell:: compile
	$(verbose) $(REBAR) as shell lsp
