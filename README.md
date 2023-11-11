
<!-- README.md is generated from README.Rmd. Please edit that file -->

# CVD Project

The project is organized into the following main folders based on data
collection/management activities:

## Folder Structure

1.  `01_Community_Screening`: All community screening work is documented
    in this folder.
2.  `02_Confirmation_Tool`: All confirmation visit work is documented
    here.
3.  `03_Confirmation_Additional_Question`: Additional questions related
    to confirmation visits can be found in this folder.
4.  `04_SPPID_Vs_Enrollment_Check`: The SPP ID and enrollment
    participant dataset matching verification work is also documented
    here.
5.  `05_CVD_Screening_Dashboard`: All project data collection work will
    be presented in a dashboard, and all dashboard development will be
    documented here.
6.  `06_VHW_Logbook`: the VHW logbook monthly data processing work will
    be documented here.

Inside each folder, the script files are documented according to their
applied function and workflow order. In general, each folder includes a
script file documenting the import of raw data, performing
high-frequency checking to create clean datasets, and conducting
analysis work.

- `01_import`: This folder contains all the dofiles used to import raw
  data.
- `02_hfc`: The dofiles in this folder are used for data collection work
  that involves high-frequency checks. This includes duplicate checks
  and verification of important calculations used in survey programming
  and progress monitoring.
- `03_clean`: All the dofiles used for data cleaning can be found in
  this folder.
- `04_construct`: This folder contains dofiles used for constructing
  reporting variables and indicators.
- `05_analysis`: This is the folder where all analysis dofiles or other
  software script files are documented.

## Dashboard

This project will develop a dashboard for each main data collection
activity. All deployed or working versions of the dashboard will be
updated here based on the project timeline.

1.  [Community
    Screening](https://nicholustintzaw.shinyapps.io/cvd_screening_monitoring/) -
    pls note this is just a working version.
2.  [Confirmation Visit](): TBC
3.  [VHW Logbook](): TBC

## DATA Folder

Please note that all dataset related to this project are hosted at the
project BOX folder in the following directory:

`Box\Myanmar CVD Study 2023-2024\Feasibility Study`

The folder organization in BOX is almost identical to the dofile/script
file hosting filing system, following the same workflow management. You
will find similar folder names listed in the BOX, and inside each main
activity folder, you will see an identical structure of all data
organized folder based on the output from the dofile/script file applied
from here.
