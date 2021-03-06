#!/bin/bash

__scriptpath=$(cd "$(dirname "$0")"; pwd -P)
__msbuildpath=$__scriptpath/../msbuild/bin/Unix/Debug-MONO/MSBuild.exe
__referenceassemblyroot=/usr/lib/mono/xbuild-frameworks
__monoversion=$(mono --version | grep "version 4.[1-9]")

if [ $? -ne 0 ]; then
    echo "Mono 4.1 or later is required to build corefx. Please see https://github.com/dotnet/corefx/wiki/Building-On-Unix for more details."
    exit 1
fi

if [ ! -e "$__referenceassemblyroot/.NETPortable" ]; then
    echo "PCL reference assemblies not found. Please see https://github.com/dotnet/corefx/wiki/Building-On-Unix for more details."
    exit 1
fi

if [ ! -e "$__msbuildpath" ]; then
    echo "MSBuild.exe required at $__msbuildpath. Please see https://github.com/dotnet/corefx/wiki/Building-On-Unix for more details."
    exit 1
fi

if [ $(uname) == "Linux" ]; then
    __osgroup=Linux
else
    __osgroup=OSX
fi

__buildproj=$__scriptpath/build.proj
__buildlog=$__scriptpath/msbuild.log

MONO29679=1 ReferenceAssemblyRoot=$__referenceassemblyroot mono $__msbuildpath "$__buildproj" /nologo /verbosity:minimal "/fileloggerparameters:Verbosity=diag;LogFile=$__buildlog" /t:Build /p:OSGroup=$__osgroup /p:UseRoslynCompiler=true /p:COMPUTERNAME=$(hostname) /p:USERNAME=$(id -un) "$@"
BUILDERRORLEVEL=$?

echo

# Pull the build summary from the log file
tail -n 4 "$__buildlog"
echo Build Exit Code = $BUILDERRORLEVEL

exit $BUILDERRORLEVEL
