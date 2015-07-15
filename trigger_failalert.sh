#!/bin/bash

source failure_alert.sh

if [[ -z $@ ]]; then
    echo Failure will alert;
    false;
else
    echo Success;
    exit 0;
fi

