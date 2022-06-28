SCRIPT="${BASH_SOURCE[0]}"
JAGSDK="`dirname "${SCRIPT}"`"
JAGSDK="`readlink -f "${JAGSDK}"`"
export JAGSDK

echo "Setting up Jaguar SDK paths using:"
echo ""
echo "  ${JAGSDK}"
echo ""
echo "as the base directory"

export RDBRC="${JAGSDK}/jaguar/bin/rdb.rc"
export DBPATH="${JAGSDK}/jaguar/bin"
export ALNPATH="${JAGSDK}/jaguar/bin"
export RMACPATH="${JAGSDK}/jaguar/include;${JAGSDK}/jaguar/skunk/include"
export MACPATH="${JAGSDK}/jaguar/include;${JAGSDK}/jaguar/skunk/include"
export PATH="${JAGSDK}/tools/bin:${JAGSDK}/jaguar/bin/linux:${PATH}"
export PYTHONPATH="${JAGSDK}/tools/lib/python:${PYTHONPATH}"
