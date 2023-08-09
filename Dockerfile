# Choose a base image
FROM ubuntu:22.04

# Install prerequisites
RUN apt-get update && \
    apt-get install -y build-essential git curl python3 gfortran

# # Install Spack
# RUN git clone https://github.com/spack/spack.git && \
#     . /spack/share/spack/setup-env.sh

# # Configure Spack environment
# ENV PATH=/spack/bin:$PATH
# ENV CC=/usr/bin/gcc
# ENV CXX=/usr/bin/g++
# ENV F77=/usr/bin/gfortran

# # Install software with Spack
# RUN . /spack/share/spack/setup-env.sh && spack install \
# cmake \
# ninja \
# ccache \
# openmpi

# Now we install spack and find compilers/externals
RUN mkdir -p /opt/ && cd /opt/ && git clone --depth 1 --branch "v0.20.1" https://github.com/spack/spack.git
RUN . /opt/spack/share/spack/setup-env.sh && spack compiler find
RUN . /opt/spack/share/spack/setup-env.sh && spack external find --not-buildable && spack external list

## Make trilinos env
RUN mkdir -p /opt/spack-trilinos-env
ADD ./spack-trilinos-depends.yaml /opt/spack-trilinos-env/spack-trilinos-depends.yaml
RUN mv /opt/spack-trilinos-env/spack-trilinos-depends.yaml /opt/spack-trilinos-env/spack.yaml
# create pre_trilinos environment from spack.yaml and concretize
RUN cd /opt/spack-trilinos-env \
  && . /opt/spack/share/spack/setup-env.sh && spack env create pre_trilinos /opt/spack-trilinos-env/spack.yaml\
  && spack env activate pre_trilinos && spack concretize && spack env deactivate
# make trilinos env from lock
RUN . /opt/spack/share/spack/setup-env.sh && spack env create trilinos /opt/spack/var/spack/environments/pre_trilinos/spack.lock
# activate trilinos env and install
RUN . /opt/spack/share/spack/setup-env.sh && spack env activate trilinos && spack install --fail-fast && spack gc -y && spack env deactivate

# Cleanup
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set the entry point
CMD ["/bin/bash"]
