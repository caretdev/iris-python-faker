FROM intersystemsdc/iris-community

ARG MODULE=python-faker

# Install python3-pip
USER root

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y python3-pip && rm -rf /var/lib/apt/lists/*

USER ${ISC_PACKAGE_IRISUSER}

ARG TESTS=0

ENV PIP_TARGET=${ISC_PACKAGE_INSTALLDIR}/mgr/python

RUN --mount=type=bind,src=.,dst=. \
  pip3 install -r requirements.txt && \
  iris start iris && \
  iris session iris "##class(%ZPM.PackageManager).Shell(\"load /home/irisowner/$MODULE -v\",1,1)" && \
  ([ $TESTS -eq 0 ] || iris session iris "##class(%ZPM.PackageManager).Shell(\"test $MODULE -v -only\",1,1)") && \
  iris stop iris quietly
