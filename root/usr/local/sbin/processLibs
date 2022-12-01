#!/bin/sh

ARCH=$(uname -m)

if [ "${ARCH}" = "x86_64" ]
then
  ldd telerising | grep "=> /" | awk '{print $3}' | xargs -I '{}' cp --no-clobber -v '{}' .
fi

if [ "${ARCH}" = "aarch64" ]
then
  ldd telerising | grep "=> /" | awk '{print $3}' | xargs -I '{}' cp --no-clobber -v '{}' .
fi

if [ "${ARCH}" = "armv7l" ]
then
  ldd telerising | grep "=> /" | awk '{print $3}' | xargs -I '{}' cp --no-clobber -v '{}' .
fi