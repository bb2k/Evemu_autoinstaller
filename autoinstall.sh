#!/bin/bash

# This Scirpt intend to automatise EvEmu installation
# - Initialize all directory struture
# - Get the latest evemu github repo
# - Configure the server
#
# This is a art of Evemu Project : https://github.com/evemuproject/evemu_server.git
#
# Author : BB2k

SRC_DIR='sources'
REPOSITORY="https://github.com/evemuproject/evemu_server.git"

DB_HOST=<hostname or IP of database>
DB_NAME=evemu
DB_USER=evemu
DB_PASS=xxxxx

if [ "$(id -u)" != "0" ]; then
	echo "Sorry, you are not root."
	exit 1
fi

PKG_OK=$(dpkg-query -W --showformat='${Status}\n' doxygen|grep "install ok installed")
if [ "" == "$PKG_OK" ]; then
  echo "* Installing Required packages"
  sudo apt-get install -y cmake git make g++ libmysqlclient-dev zlib1g zlib1g-dev libboost-all-dev doxygen > /dev/null
fi

echo "* Downloading Github Repo"
if [ ! -d $SRC_DIR ]; then
  git clone $REPOSITORY  $SRC_DIR > /dev/null
else
  cd $SRC_DIR
  git pull
  cd ..
fi

echo "* Configuring CMake"

cd $SRC_DIR

if [ ! -d "build" ]; then
 mkdir build
fi

cd build

cmake  -Wno-dev ../. > /dev/null

echo "* Compiling Software"

let num_proc=`cat /proc/cpuinfo | grep processor | wc -l`-1
make -j $num_proc > /dev/null

cd ../..

if [ ! -d "bin" ]; then
  echo "* building directory structure"
  mkdir bin
fi

if [ ! -d "log" ]; then
  mkdir log
fi

if [ ! -d "etc" ]; then
  mkdir etc
fi

if [ ! -f "bin/eve-server" ]; then
  echo "* Copying compiled files"
  ln -s ../$SRC_DIR/build/src/eve-server/eve-server bin/
fi

if [ ! -f "etc/eve-server.xml" ]; then
cat > etc/eve-server.xml <<EOF
<!--
The goal of this file is to specify as little as possible. Try the defaults
for each parameter, and set them only if it does not work. (DB params are
a likely exception to this goal).
-->
<eve-server>
    <rates>
        <!-- <corporationStartupCost>1599800</corporationStartupCost> -->
        <!-- <skillRate>1.0</skillRate> -->
        <!-- <secRate>1.0</secRate> -->
        <!-- <npcBountyMultiply>1.0</npcBountyMultiply> -->
    </rates>

    <account>
         <autoAccountRole>2</autoAccountRole>
        <!-- <loginMessage>
            &lt;html&gt;
                &lt;head&gt;
                &lt;/head&gt;
                &lt;body&gt;
                    Welcome to &lt;b&gt;EVEmu live build server&lt;/b&gt;.&lt;br&gt;
                    &lt;br&gt;
                    You can find a lot of interesting information about this project at &lt;a href=&quot;http://forum.evemu.org/&quot;&gt;forum.evemu.org&lt;/a&gt;.&lt;br&gt;
                    &lt;br&gt;
                    You can also join our IRC channel at &lt;b&gt;evemu.levelbelow.net:6667&lt;/b&gt;, channel &lt;b&gt;#evemu&lt;/b&gt;.&lt;br&gt;
                    &lt;br&gt;
                    Best wishes,&lt;br&gt;
                    EVEmu development team
                &lt;/body&gt;
            &lt;/html&gt;
        </loginMessage> -->
    </account>

    <character>
        <!-- <startBalance>6666000000.0</startBalance> -->
        <!-- <startStation>0</startStation> -->
        <!-- <startSecRating>0.0</startSecRating> -->
        <!-- <startCorporation>0</startCorporation> -->
    </character>

    <database>
        <host>${DB_HOST}</host>
        <username>${DB_USER}</username>
        <password>${DB_PASS}</password>
        <db>${DB_NAME}</db>
        <!-- <port>3306</port> -->
    </database>

    <files>
        <logDir>../log/</logDir>
        <logSettings>../etc/log.ini</logSettings>
        <cacheDir>../server_cache/</cacheDir>
        <imageDir>../image_cache/</imageDir>
    </files>

    <net>
        <!-- <imageServer>localhost</imageServer> -->
        <!-- <imageServerPort>26001</imageServerPort> -->
        <!-- <apiServer>localhost</apiServer> -->
        <!-- <apiServerPort>50001</apiServerPort> -->
    </net>

</eve-server>
EOF
fi 

if [ ! -f "etc/log.ini" ]; then
  cat >etc/log.ini <<EOF
# EVEmu Log Settings:

# Debug Logging:
DEBUG=1
DEBUG__DEBUG=1


# Network Activity Logging:
NET=0
NET__PRES_ERROR=1
NET__PRES_DEBUG=0
NET__PRES_TRACE=1
NET__PRES_REP=0
NET__PRES_RAW=0
NET__PRES_REP_OUT=0
NET__PRES_RAW_OUT=0
NET__MARSHAL_ERROR=1
NET__MARSHAL_TRACE=0
NET__UNMARSHAL_TRACE=0
NET__UNMARSHAL_BUFHEX=0
NET__UNMARSHAL_ERROR=1
NET__ZEROINFL=0
NET__ZEROCOMP=0
NET__PACKET_ERROR=1
NET__PACKET_WARNING=0
NET__DISPATCH_ERROR=0


# Packet Collection Logging:
COLLECT=0
COLLECT__MESSAGE=0
COLLECT__ERROR=1
COLLECT__ERROR_DETAIL=1
COLLECT__TCP=0
COLLECT__RAW_HEX=0
COLLECT__PYREP_DUMP=0
COLLECT__PACKET_DUMP=0
COLLECT__PACKET_SRC=0
COLLECT__PACKET_DEST=0
COLLECT__CALL_SUMMARY=0
COLLECT__DESTINY=0
COLLECT__DESTINY_REP=0
COLLECT__DESTINY_HEX=0
COLLECT__CALL_DUMP=0
COLLECT__NOTIFY_SUMMARY=0
COLLECT__NOTIFY_DUMP=0
COLLECT__OTHER_DUMP=0
COLLECT__CALL_XML=0
COLLECT__CALLRSP_XML=0
COLLECT__NOTIFY_XML=0
COLLECT__MISC_XML=0
COLLECT__CALLRSP_SQL=0


# Service Logging:
SERVICE=1
SERVICE__ERROR=1
SERVICE__WARNING=0
SERVICE__CALLS=0
SERVICE__MESSAGE=1
SERVICE__CACHE=0
SERVICE__CACHE_DUMP=0
SERVICE__CALL_TRACE=1


# Spawn Logging:
SPAWN=0
SPAWN__ERROR=1
SPAWN__WARNING=0
SPAWN__MESSAGE=0
SPAWN__POP=0
SPAWN__DEPOP=0


# Item Logging:
ITEM=0
ITEM__ERROR=1
ITEM__WARNING=0
ITEM__MESSAGE=0
ITEM__DEBUG=0
ITEM__TRACE=0


# NPC Logging:
NPC=0
NPC__ERROR=1
NPC__WARNING=0
NPC__MESSAGE=0
NPC__TRACE=0
NPC__AI_TRACE=0


# Agent Logging:
AGENT=0
AGENT__ERROR=1
AGENT__WARNING=0
AGENT__MESSAGE=0
AGENT__TRACE=0


# Market Logging:
MARKET=0
MARKET__ERROR=1
MARKET__WARNING=0
MARKET__MESSAGE=0
MARKET__DEBUG=0
MARKET__TRACE=0


# Mining Logging:
MINING=0
MINING__ERROR=1
MINING__WARNING=0
MINING__MESSAGE=0
MINING__DEBUG=0
MINING__TRACE=0


# Destiny Logging:
DESTINY=0
DESTINY__ERROR=1
DESTINY__WARNING=0
DESTINY__MESSAGE=0
DESTINY__DEBUG=0
DESTINY__TRACE=0
DESTINY__BUBBLE_DEBUG=0
DESTINY__BUBBLE_TRACE=0
DESTINY__UPDATES=0


# Physics Logging:
PHYSICS=0
PHYSICS__ERROR=1
PHYSICS__MESSAGE=0
PHYSICS__TRACE=0
PHYSICS__TRACEPOS=0


# Common Logging:
COMMON=0
COMMON__ERROR=1
COMMON__WARNING=0
COMMON__MESSAGE=0
COMMON__THREADS=0
COMMON__PYREP=0


# Server Logging:
SERVER=1
SERVER__INIT_ERR=1
SERVER__INIT=1
SERVER__CLIENTS=1
SERVER__SHUTDOWN=1


# Command Logging:
COMMAND=1
COMMAND__ERROR=1
COMMAND__MESSAGE=0


# Ship Logging:
SHIP=0
SHIP__ERROR=1
SHIP__MODULE_TRACE=0
SHIP__MODULE_AGGREGATE=0


# Target Logging:
TARGET=0
TARGET__ERROR=1
TARGET__DEBUG=0
TARGET__TRACE=0


# LSC Logging:
LSC=0
LSC__ERROR=1
LSC__MESSAGE=0
LSC__CHANNELS=0


# Client Logging:
CLIENT=1
CLIENT__ERROR=1
CLIENT__MESSAGE=1
CLIENT__CALL_REP=1
CLIENT__CALL_DUMP=1
CLIENT__IN_ALL=0
CLIENT__NOTIFY_REP=0
CLIENT__NOTIFY_DUMP=0
CLIENT__SESSION=1
CLIENT__TRACE=1
CLIENT__TEXT=0


# CClient Logging:
CCLIENT=1
CCLIENT__ERROR=1
CCLIENT__INIT_ERR=1
CCLIENT__INIT=1
CCLIENT__MESSAGE=1
CCLIENT__CLIENTS=1
CCLIENT__SHUTDOWN=0
CCLIENT__IN_ALL_DUMP=0
CCLIENT__IN_DUMP=0
CCLIENT__OUT_ALL_DUMP=0
CCLIENT__SESSION=0
CCLIENT__BINDS=0


# Database Logging:
DATABASE=1
DATABASE__MESSAGE=1
DATABASE__ERROR=1
DATABASE__QUERIES=1
DATABASE__RESULTS=1
DATABASE__ALL_ERRORS=1
DATABASE__PACKED=1
EOF
fi

cat > start.sh << EOF
#!/bin/bash

cd bin
./eve-server
EOF
chmod u+x start.sh
