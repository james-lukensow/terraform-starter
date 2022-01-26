ifndef ENV
$(error environment variable ENV is not set)
endif

ifeq (,$(wildcard $(ROOTDIR)/config/${ENV}.json))
$(error environment file config/${ENV}.json not found)
endif