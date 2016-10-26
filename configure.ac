AC_INIT([ROracle], 1.3-1)

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
            AC_HELP_STRING([--with-oci-lib=OCI_LIBRARY_PATH],
                           [the location of OCI libraries]),
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
      else
        AC_MSG_ERROR([OCI libraries not found])
      fi
    fi
  fi
fi
if test [ ! -d "${ROCI_LIBS}" ] ; then
  AC_MSG_ERROR(["${ROCI_LIBS}" directory does not exist])
fi

dnl select include path from a configure option or from an environment
dnl variable or from a standard location.
AC_ARG_WITH([oci-inc],
            AC_HELP_STRING([--with-oci-inc=OCI_INCLUDE_PATH],
                           [the location of OCI header files]),
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

dnl set complier flags
ROCI_LIBS="-L${ROCI_LIBS} -lclntsh -Wl,-rpath,${ROCI_LIBS}"
ROCI_CPPFLAGS="-I${ROCI_CPPFLAGS}"
## For Mac use rpath to link
case "${host_os}" in
  darwin*)
    ROCI_LIBS="-L${ROCI_LIBS} -lclntsh -Wl,-rpath,${ROCI_LIBS}"
  ;;
esac

dnl substitute complier flags
AC_SUBST(ROCI_CPPFLAGS)
AC_SUBST(ROCI_LIBS)

dnl and do subsitution in the src/Makevars.in
AC_CONFIG_FILES([src/Makevars])
AC_OUTPUT
