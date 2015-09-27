---
title: "Getting and Cleaning Data - Course Project"
author: "Aaron Kirschner"
date: "September 27, 2015"
output:
  html_document:
    keep_md: yes
---


## This repository contains the following:
* __README.md__ - This file.
* __CodeBook.md__ - File containing information on dataset, including variables and transformations performed.
* __run_analysis.R__ - R Script designed to collect, aggregate, and clean up data.

### How to create the tidy dataset
####_NOTE:_ The `dplyr` and `tidyr` packages must be installed for this script to function.

1. Set working directory of your choosing. 
2. Save `run_analysis.R` to working directory.
3. Download [compressed data set](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip).
4. Unzip raw data and copy the `UCI HAR Dataset` folder to working directory.
5. Using either R or RSTudio, execute `source("run_analysis.R")`.
6. Tidy data set will be output to `meansBySubjectAndActivity.txt` in working directory.

