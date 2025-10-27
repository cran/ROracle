AC_INIT([ROracle], 1.5-0)

dnl find standard Instant Client installation
: ${R_HOME=`R RHOME`}
if test -z "${R_HOME}"; then
  echo "could not determine R_HOME"
  exit 1
fi
libnn=`"${R_HOME}/bin/R" CMD config LIBnn`
if test "$libnn" = "lib64" ; then
  oci_client_lib="/usr/lib/oracle/11.2/client64/lib"
  oci_client_inc="/usr/include/oracle/11.2/client64"
else
  oci_client_lib="/usr/lib/oracle/11.2/client/lib"
  oci_client_inc="/usr/include/oracle/11.2/client"
fi

dnl select library path from a configure option or from an environment
dnl variable or from a standard location.
AC_ARG_WITH([oci-lib],
            AS_HELP_STRING([--with-oci-lib=OCI_LIBRARY_PATH],[the location of OCI libraries]),
            [oci_library=$withval])
if test [ -n "$oci_library" ] ; then
  ROCI_LIBS=${oci_library}
else
  if test [ -n "${OCI_LIB}" ] ; then
    ROCI_LIBS=${OCI_LIB}
  else
    if test [ -n "${ORACLE_HOME}" ] ; then
      ROCI_LIBS="${ORACLE_HOME}/lib"
    else
      if test [ -d "$oci_client_lib" ] ; then
        ROCI_LIBS=${oci_client_lib}
      fi
    fi
  fi
fi

dnl If no libraries found locally, attempt download
AC_PATH_PROG([CURL], [curl])

if test [ ! -d "${ROCI_LIBS}" ] ; then
  if test -n "$CURL"; then
    AC_DEFINE(HAVE_CURL, 1, [Define if curl is present])
  else
    AC_DEFINE(HAVE_CURL, 0, [Define if curl is NOT present])
  fi

  AC_SUBST(CURL)

  AC_DEFINE(CURL_LOCATION, "$CURL", [Path to wget if available])

  if test "$CURL" != ""; then
    dnl Normalize OS type
    os=$(uname)

    case "$os" in
      aix*|AIX*)           os="aix" ;;
      Darwin*|darwin*|*BSD*|*bsd*) os="darwin" ;;
      hpux*|HP-UX*)        os="hpux" ;;
      linux*|Linux*|mklinux*) os="linux" ;;
      solaris*|SunOS*)     os="solaris" ;;
    esac

    arch=`uname -m`
    case "$os" in
      aix)
        bit_arch=$(getconf KERNEL_BITMODE)
        case "$bit_arch" in
          32)
            downloaded_file_url="https://download.oracle.com/otn_software/aix/instantclient/instantclient-sdk-aix-ppc32.zip";
            downloaded_file_name="instantclient-sdk-aix-ppc32.zip";;
          *)
            downloaded_file_url="https://download.oracle.com/otn_software/aix/instantclient/instantclient-sdk-aix.zip";
            downloaded_file_name="instantclient-sdk-aix.zip";;
        esac
        ;;
      darwin)
        case "$arch" in
            arm64*) 
              downloaded_file_url="https://download.oracle.com/otn_software/mac/instantclient/instantclient-sdk-macos-arm64.dmg"; 
              downloaded_file_name="instantclient-sdk-macos-arm64.dmg";;
            *) 
            downloaded_file_url="https://download.oracle.com/otn_software/mac/instantclient/instantclient-sdk-macos.zip"; 
            downloaded_file_name="instantclient-sdk-macos.zip";;
        esac;;
      hpux)
        downloaded_file_url="https://download.oracle.com/otn_software/hp/instantclient/instantclient-sdk-hpia64.zip"; 
        downloaded_file_name="instantclient-sdk-hpia64.zip";;
      linux)
        case "$arch" in
          x86_64) 
            downloaded_file_url="https://download.oracle.com/otn_software/linux/instantclient/instantclient-sdk-linuxx64.zip"; 
            downloaded_file_name="instantclient-sdk-linuxx64.zip";;
          *86*) 
              downloaded_file_url="https://download.oracle.com/otn_software/linux/instantclient/instantclient-sdk-linux.zip"; 
              downloaded_file_name="instantclient-sdk-linux.zip";;
          aarch64*) 
            downloaded_file_url="https://download.oracle.com/otn_software/linux/instantclient/instantclient-sdk-linux-arm64.zip"; 
            downloaded_file_name="instantclient-sdk-linux-arm64.zip";;
          ppc64le*) 
            downloaded_file_url="https://download.oracle.com/otn_software/linux/instantclient/instantclient-sdk-linuxleppc.zip"; 
            downloaded_file_name="instantclient-sdk-linuxleppc.zip";;
          s390*) 
            downloaded_file_url="https://download.oracle.com/otn_software/linux/instantclient/instantclient-sdk-linuxz64.zip"; 
            downloaded_file_name="instantclient-sdk-linuxz64.zip";;
        esac;;
      solaris)
        case "$arch" in
          sun*) 
            downloaded_file_url="https://download.oracle.com/otn_software/solaris/instantclient/instantclient-sdk-solaris64.zip"; 
            downloaded_file_name="instantclient-sdk-solaris64.zip";;
          *86*) 
            downloaded_file_url="https://download.oracle.com/otn_software/solaris/instantclient/instantclient-sdk-solarisx64.zip"; 
            downloaded_file_name="instantclient-sdk-solarisx64.zip";;
        esac;;
      *) 
        downloaded_file_url="https://download.oracle.com/otn_software/$(uname)/instantclient/instantclient-sdk-$(uname).zip"; 
        downloaded_file_name="instantclient-sdk-$(uname).zip";;
    esac

    AC_MSG_CHECKING([downloading $downloaded_file_name])
    if $CURL -O $downloaded_file_url; then
      AC_MSG_RESULT([downloaded $downloaded_file_name])
    else
      AC_MSG_ERROR([Failed to download $downloaded_file_name])
    fi

    AC_MSG_CHECKING([extracting $downloaded_file_name])

    case "$downloaded_file_name" in
      *.zip)
        AC_PATH_PROG([UNZIP], [unzip])
        if $UNZIP -u "$downloaded_file_name"; then
          AC_MSG_RESULT([unzipped $downloaded_file_name])
        else
          AC_MSG_ERROR([Failed to extract $downloaded_file_name. OCI headers required for compilation are missing.])
        fi

        directory=`$UNZIP -l "$downloaded_file_name" | grep -m1 'instantclient_' | awk '{print $4}' | awk -F/ '{print $1}'`
        ROCI_LIBS="./$directory"
        ROCI_LIBS=$(cd "$ROCI_LIBS"; pwd)
        ;;

      *.dmg)
        AC_PATH_PROG([HDIUTIL], [hdiutil])
        RAND_ID=$RANDOM$$
        MOUNT_POINT="/Volumes/InstantClientMount_$RAND_ID"
        if $HDIUTIL attach "$downloaded_file_name" -mountpoint "$MOUNT_POINT" -nobrowse -quiet; then
          AC_MSG_RESULT([mounted $downloaded_file_name at $MOUNT_POINT])
        else
          AC_MSG_ERROR([Failed to mount $downloaded_file_name. OCI headers required for compilation are missing.])
        fi
        directory=`ls "$MOUNT_POINT" | grep -m1 'instantclient_'`
        ROCI_LIBS="$MOUNT_POINT/$directory"

        cp -R "$ROCI_LIBS" ./ && $HDIUTIL detach "$MOUNT_POINT" -quiet
        ROCI_LIBS="./$directory"
        ROCI_LIBS=$(cd "$ROCI_LIBS"; pwd)

        AC_MSG_RESULT([mounted and found $ROCI_LIBS]);;
    esac
  fi
fi

dnl select include path from a configure option or from an environment
dnl variable or from a standard location.
AC_ARG_WITH([oci-inc],
            AS_HELP_STRING([--with-oci-inc=OCI_INCLUDE_PATH],[the location of OCI header files]),
            [oci_include=$withval])
if test [ -n "$oci_include" ] ; then
  ROCI_CPPFLAGS=${oci_include}
else
  if test [ -n "${OCI_INC}" ] ; then
    ROCI_CPPFLAGS=${OCI_INC}
  else
    if test [ -n "${ORACLE_HOME}" ] ; then
      ROCI_CPPFLAGS="${ORACLE_HOME}/rdbms/public"
    else
      if test [ -d "$oci_client_inc" ] ; then
        ROCI_CPPFLAGS=${oci_client_inc}
      else
        if test [ -d "${ROCI_LIBS}/sdk/include" ] ; then
          ROCI_CPPFLAGS="${ROCI_LIBS}/sdk/include"
        else
          AC_MSG_ERROR([OCI headers not found])
        fi
      fi
    fi
  fi
fi
if test [ ! -d "${ROCI_CPPFLAGS}" ] ; then
  AC_MSG_ERROR(["${ROCI_CPPFLAGS}" directory does not exist])
fi

os=$(uname)
dnl set complier flags
case "$os" in
  AIX)
    ROCI_LIBS="-L${ROCI_LIBS} -Wl,-blibpath:${ROCI_LIBS}";;
  *)
    ROCI_LIBS="-L${ROCI_LIBS} -Wl,-rpath,${ROCI_LIBS}";;
esac
ROCI_CPPFLAGS="-I${ROCI_CPPFLAGS}"

dnl substitute complier flags
AC_SUBST(ROCI_CPPFLAGS)
AC_SUBST(ROCI_LIBS)

dnl and do subsitution in the src/Makevars.in
AC_CONFIG_FILES([src/Makevars])
AC_OUTPUT
