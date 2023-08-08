FROM ubuntu:22.04

RUN apt-get update

RUN apt-get install git
RUN apt-get install ninja
RUN apt-get install ccache
RUN apt-get install cmake
RUN apt-get install openmpi