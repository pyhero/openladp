#!/bin/bash
#

cmd=$script_dir/sendEmail
[ ! -x $cmd ] && exit 2

## need define variables:
##		title:mail title
##		body:mail body

/usr/bin/printf "%b" "$body" | \
	$cmd -f notify@aiuv.cc \
		-t $mail \
		-s smtp.qq.com \
		-u "$title" \
		-xu notify@aiuv.cc \
		-xp Xu1991MNbula \
		-o message-content-type=html \
		> /dev/null
