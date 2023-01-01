#!/bin/sh
# Copyright (c) 2017 Oracle and/or its affiliates. All Rights Reserved.
# Copyright (c) International Business Machines  Corp., 2000
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of
# the License, or (at your option) any later version.
#
# This program is distributed in the hope that it would be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

TCID="rpc01"
TST_TOTAL=6
TST_CLEANUP=do_cleanup

TST_USE_LEGACY_API=1
. tst_net.sh

NUMLOOPS=${NUMLOOPS:=3}
DATAFILES=${DATAFILES:="file.1 file.2"}

do_cleanup()
{
	pkill -9 rpc_server > /dev/null 2>&1
}

do_setup()
{
	tst_resm TINFO "start rpc_server"
	rpc_server

	tst_resm TINFO "wait for server to be registered"
	for i in $(seq 1 30); do
		rpcinfo -T udp $(tst_ipaddr) 2000333 10 >/dev/null 2>&1 && break
		[ "$i" -eq 30 ] && tst_brkm TBROK "server not registered"
		tst_sleep 100ms
	done
}

do_test()
{
	local thost="$(tst_ipaddr)"

	tst_resm TINFO "starting client process"
	local cnt=1
	while [ $cnt -le $NUMLOOPS ]; do
		for f in $DATAFILES; do
			EXPECT_RHOST_PASS rpc1 -s $thost -f $LTP_DATAROOT/$f
		done
		cnt=$(($cnt + 1))
	done
}

do_setup
do_test

tst_exit
