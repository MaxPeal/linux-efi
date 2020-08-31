#!/bin/sh
#:
set -vx
LANG=C
LC_MESSAGES=C
LC_ALL=C

# http://www.etalabs.net/sh_tricks.html
echo () (
fmt=%s end=\\n IFS=" "

while [ $# -gt 1 ] ; do
case "$1" in
[!-]*|-*[!ne]*) break ;;
*ne*|*en*) fmt=%b end= ;;
*n*) end= ;;
*e*) fmt=%b ;;
esac
shift
done

printf "$fmt$end" "$*"
)
quote () { printf %s\\n "$1" | sed "s/'/'\\\\''/g;1s/^/'/;\$s/\$/'/" ; }


# from https://github.com/sameersbn/docker-redmine/blob/master/assets/runtime/functions#L16-L30
# Read YAML file from Bash script
# Credits: https://gist.github.com/pkuczynski/8665367
# Updated to support single quotes
parse_yaml() {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\)\($w\)$s:$s\"\(.*\)\"$s\$|\1$fs\2$fs\3|p" \
       -ne "s|^\($s\)\($w\)$s:$s'\(.*\)'$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p" $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}




####rm *.env
ENVDIR=${PWD}/buildout-env
rm EOF.env
rm $ENVDIR/EOF.env
#cat > EOF.env <<"EOFvar"
MARKER-START:
IMAGE_NAME="alpine:latest"
DOCKER_CONTAINER_NAME="alpine-get-linux-version-run"
A_URL="http://dl-cdn.alpinelinux.org/alpine"
A_BRANCH="v3.12"
A_BRANCH="latest-stable"
A_APK_FULL="--repository=${A_URL}/${A_BRANCH}/main --repository=${A_URL}/${A_BRANCH}/community"
A_APK_FULL_edge="${A_APK_FULL} --repository=${A_URL}/edge/testing --repository=${A_URL}/edge/community"
MARKER-END:
#EOFvar

MARKER-START2:
foo
MARKER-END2:



#payload_offset=$(($(grep -na -m1 "^MARKER:$" $0|cut -d':' -f1) + 1))
payload_offset_start=$(($(grep -na -m1 "^MARKER-START:$" $0|cut -d':' -f1) + 1))
payload_offset_end=$(($(grep -na -m1 "^MARKER-END:$" $0|cut -d':' -f1) - 1))
payload_offset_start2=$(($(grep -na -m1 "^MARKER-START2:$" $0|cut -d':' -f1) + 1))
payload_offset_end2=$(($(grep -na -m1 "^MARKER-END2:$" $0|cut -d':' -f1) - 1))
#MARKER:
#tail -n +$payload_offset $0|
[ "$payload_offset" = "1" ] && exit 1 
#tail -n +$payload_offset $0 > tail.out
#tail -n +$payload_offset $0| tar tvJ || exit 1
rm tail.out tail_start.out tail_end.out head_end.out
tail -n +$payload_offset_start $0 > tail_start.out
head -n -$payload_offset_end $0 > head_end.out
tail -n +$payload_offset_start $0 | head -n -$payload_offset_end > tail_end.out
head -n -$payload_offset_end $0 | tail -n +$payload_offset_start > head-tail.out

head -$payload_offset_start $0 |tail -$(($payload_offset_end - $payload_offset_start)) > head-tail-test.out
sed -n ''"$payload_offset_start"','"$payload_offset_end"'p;'"$payload_offset_end"'q' <$0 > sed-test.out
sed -n ''"$payload_offset_start2"','"$payload_offset_end2"'p;'"$payload_offset_end2"'q' <$0 > sed-test2.out
sed -n -e ''"$payload_offset_start2"','"$payload_offset_end2"'p;'"$payload_offset_end2"'q' <$0 | cut -d"=" -f1 > sed-test3.out
VARlist=$(sed -n -e ''"$payload_offset_start"','"$payload_offset_end"'p;'"$payload_offset_end"'q' <$0 | cut -d"=" -f1)
VARlist2=$(sed -n -e ''"$payload_offset_start"','"$payload_offset_end"'p;'"$payload_offset_end"'q' <$0 | cut -d"=" -f2)
VARlist3=$(sed -n -e ''"$payload_offset_start"','"$payload_offset_end"'p;'"$payload_offset_end"'q' <$0 )
#rm *.env
sed -n -e ''"$payload_offset_start"','"$payload_offset_end"'p;'"$payload_offset_end"'q' <$0 > EOF2.env
#sed -n -e ''"$payload_offset_start"','"$payload_offset_end"'p;'"$payload_offset_end"'q' <$0 > EOF.env

echo "ENVDIR=$ENVDIR" >> $ENVDIR/EOF.env
echo "IMAGE_NAME=$IMAGE_NAME" >> $ENVDIR/EOF.env
echo "DOCKER_CONTAINER_NAME=$DOCKER_CONTAINER_NAME" >> $ENVDIR/EOF.env
echo "A_URL=$A_URL" >> $ENVDIR/EOF.env
echo "A_BRANCH=$A_BRANCH" >> $ENVDIR/EOF.env
echo "A_APK_FULL=$A_APK_FULL" >> $ENVDIR/EOF.env
echo "A_APK_FULL_edge=$A_APK_FULL_edge" >> $ENVDIR/EOF.env

#echo "$VARlist3" > EOF.env

echo "$VARlist"
echo "###############"
echo "$VARlist2"
echo "##############"
echo "$VARlist3"
echo "##############"

#esceval()
#{
#    printf '%s\n' "$1" | sed "s/'/'\\\\''/g; 1 s/^/'/; $ s/$/'/"
#}

# https://stackoverflow.com/questions/17529220/why-should-eval-be-avoided-in-bash-and-what-should-i-use-instead/52538533#52538533
function token_quote {
  local quoted=()
  for token; do
    quoted+=( "$(printf '%q' "$token")" )
  done
  printf '%s\n' "${quoted[*]}"
}

esceval()
{
    printf '%s\n' "$1" | sed "s/'/'\\\\''/g; 1 s/^/'/; $ s/$/'/"
}
fooecho()
{
	echo fooecho $@ fooecho fooecho fooecho
}


echo $VARlist
for i in $VARlist ; do
 	fooecho $i 
	#esceval $(echo "\$$i")
input2="Trying to hack you; date"
cmd2=(echo "User gave:" "$input")
ieval=$(eval "$(echo "${cmd2[@]}")")
echo $ieval
ieval=$(eval "$(token_quote "${cmd2[@]}")")
echo $ieval

cmd=(echo "$i"=$(echo "\$$i") )
ieval=$(eval "$(token_quote "${cmd[@]}")")
echo $ieval

echo fooo3
ieval=$(eval "$dest=\$$i")
echo $dest
echo $ieval

iquoted=$(quote "\$$i")
echo $iquoted
ieval=$(eval "$dest=\$$iquoted")
echo $dest
echo $ieval

echo foo4
	#esceval $i
	#esceval $(echo "\$$i")
	#eval $(esceval \$$i)
	ivar=$(eval $(echo "\$$i"))
        ivar=`echo \$i`
	echo ${ivar} 
	ivar2=$(echo $(echo $$i))
	echo $ivar
	echo $ivar2
	echo "$i=$ivar" >> $i.env
	echo "$i=$ivar2" >> envfile.env
	echo "$i=$(echo $(echo "\$$i"))" >> envfile.env  
done
###exit 0

#sed -e "s/GREP-START// 

### IMAGE_NAME=alpine:latest DOCKER_CONTAINER_NAME=alpine-get-linux-version docker run --rm -it  --name ${DOCKER_CONTAINER_NAME} ${IMAGE_NAME}
# IMAGE_NAME="alpine:latest" DOCKER_CONTAINER_NAME="alpine-get-linux-version" ; docker run --rm -it  --name ${DOCKER_CONTAINER_NAME} ${IMAGE_NAME}
cat <<"EOF" | docker run --env-file $ENVDIR/EOF.env --rm -i -v $(pwd)/$ENVDIR:/$ENVDIR -w /$ENVDIR/ --name ${DOCKER_CONTAINER_NAME} ${IMAGE_NAME}
#set -vx
# https://github.com/sameersbn/docker-redmine/blob/master/assets/runtime/functions#L16-L30
# Read YAML file from Bash script
# Credits: https://gist.github.com/pkuczynski/8665367
# Updated to support single quotes
parse_yaml() {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\)\($w\)$s:$s\"\(.*\)\"$s\$|\1$fs\2$fs\3|p" \
       -ne "s|^\($s\)\($w\)$s:$s'\(.*\)'$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p" $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
  }


  #apk add --no-cache --upgrade ${A_APK_FULL_edge} yq
#  apk add --no-cache --upgrade ${A_APK_FULL_edge} yq 
#  apk add --no-cache --upgrade $A_APK_FULL_edge yq
#  apk add --no-cache ${A_APK_FULL} curl
  date > foo
  echo 'foo' >> foo
  cat /etc/*release >> foo
  ls -altr /etc/*-release
  whoami >> foo
#LATEST_ROOTFS=$(curl -sL http://dl-cdn.alpinelinux.org/alpine/v${ALPINE_VERSION}/releases/x86_64/latest-releases.yaml | yq read - [0].version)
#LATEST_ROOTFS=$(curl -sL ${A_URL}/${A_BRANCH}/releases/x86_64/latest-releases.yaml | yq read - [0].version)
#LATEST_ROOTFS=$(wget -O- ${A_URL}/${A_BRANCH}/releases/x86_64/latest-releases.yaml | yq read - [0].version)
#LATEST_ROOTFS_for_eval=$(wget -O- ${A_URL}/${A_BRANCH}/releases/x86_64/latest-releases.yaml | parse_yaml - "yaml" | grep version | head 1)

LATEST_ROOTFS_for_eval=$(wget -O- ${A_URL}/${A_BRANCH}/releases/x86_64/latest-releases.yaml )
#eval $(parse_yaml "${LATEST_ROOTFS_for_eval}" "yaml" | grep version | head -n 1 )
# FIXME quoteing for eval
eval $(echo "${LATEST_ROOTFS_for_eval}" | parse_yaml - "yaml" | grep version | head -n 1 )
LATEST_ROOTFS_for_eval=""
LATEST_ROOTFS=$yaml_version
set
###VAR1=$LATEST_ROOTFS ; echo "$VAR1=${'$VAR1'}" | tee $DOCKER_CONTAINER_NAME.env 

linuxVERSION=$(pkgNAME="linux-lts" ; apk info --no-cache --repository=http://dl-cdn.alpinelinux.org/alpine/${A_BRANCH}/main ${pkgNAME} \
                | grep "description:" | cut -d" " -f1 | sed -e "s/${pkgNAME}//" | cut -d"-" -f2 ) && \
echo LATEST_ROOTFS: "$LATEST_ROOTFS"
echo linuxVERSION: "$linuxVERSION"
echo "LATEST_ROOTFS=$LATEST_ROOTFS" >> EOF.env
echo "linuxVERSION=$linuxVERSION" >> EOF.env

EOF

#docker run -v $(pwd)/buildout-env:/buildout-env -w /buildout-env -i alpine:3.10 /bin/sh -s <<EOF 
#date > foo
#echo 'foo' >> foo
#cat /etc/redhat-release >> foo
#whoami >> foo
#EOF

exit 0;

# https://gist.github.com/mbreese/e6d4b57867ca440341b5 

# build init from alpine base
ARG ALPINE_VERSION=3.12
ARG ALPINE_DOCKER_VERSION=3.10
FROM alpine:${ALPINE_DOCKER_VERSION} as initbasestage
ARG ALPINE_VERSION

RUN \
 echo "**** install build deps ****" && \
 apk add --no-cache --upgrade \
	curl \
	tar \
	xz 

RUN \
 echo "**** install yq form edge/testing/community repository ****" && \
 apk add --no-cache --upgrade --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community \
	yq

RUN \
 echo "**** grab Alpine ****" && \
 mkdir -p /initrd && \
 LATEST=$(curl -sL \
	http://dl-cdn.alpinelinux.org/alpine/v${ALPINE_VERSION}/releases/x86_64/latest-releases.yaml \
	| yq read - [0].version) && \
 echo $LATEST && \
 curl -o \
        /rootfs.tar.gz -L \
        "http://dl-cdn.alpinelinux.org/alpine/v${ALPINE_VERSION}/releases/x86_64/alpine-minirootfs-${LATEST}-x86_64.tar.gz" && \
 tar xf \
	/rootfs.tar.gz \
	-C /initrd

RUN \
 echo "**** grab Alpine linux-lts version ****" && \
 LATESTbranch=$(curl -sL \
	http://dl-cdn.alpinelinux.org/alpine/latest-stable/releases/x86_64/latest-releases.yaml \
	| yq read - [0].branch) && \
 echo LATESTbranch: $LATESTbranch && \
  linuxVERSION=$(pkgNAME="linux-lts" ; apk info --no-cache --repository=http://dl-cdn.alpinelinux.org/alpine/v${ALPINE_VERSION}/main ${pkgNAME} \
                | grep "description:" | cut -d" " -f1 | sed -e "s/${pkgNAME}//" | cut -d"-" -f2 ) && \
 echo linuxVERSION: "$linuxVERSION"

# build kernel
FROM alpine:${ALPINE_DOCKER_VERSION} as buildstage
#ARG KERNEL_VERSION="5.4.58"
RUN  linuxVERSION=$(pkgNAME="linux-lts" ; apk info --no-cache --repository=http://dl-cdn.alpinelinux.org/alpine/v${ALPINE_VERSION}/main ${pkgNAME} \
                | grep "description:" | cut -d" " -f1 | sed -e "s/${pkgNAME}//" | cut -d"-" -f2 ) && \
     echo linuxVERSION: "$linuxVERSION"

RUN \
 echo "**** download assets ${KERNEL_VERSION} ${linuxVERSION} $KERNEL_VERSION $linuxVERSION ****" && \
 wget https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-${KERNEL_VERSION}.tar.xz && \
 wget https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-${KERNEL_VERSION}.tar.sign && \
 xz -v -d linux-${KERNEL_VERSION}.tar.xz && \
 gpg --keyserver keyserver.ubuntu.com --recv B8868C80BA62A1FFFAF5FDA9632D3A06589DA6B1 647F28654894E3BD457199BE38DBBDC86092693E ABAF11C65A2970B130ABE3C479BE3E4300411886 && \
 gpg --verify linux-${KERNEL_VERSION}.tar.sign && \
 tar xf linux-${KERNEL_VERSION}.tar 
 
