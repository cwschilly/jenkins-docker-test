# Choose a base image
FROM ubuntu:latest

# Install prerequisites
RUN apt-get update && \
    apt-get install -y build-essential git curl python3 gcc

# Install Spack
RUN git -C $HOME clone https://github.com/spack/spack.git && \
    . $HOME/spack/share/spack/setup-env.sh

# Configure Spack environment
ENV SPACK_ROOT=$HOME/spack
ENV PATH=$SPACK_ROOT/bin:$PATH

# Install software with Spack
RUN . $HOME/spack/share/spack/setup-env.sh && spack install \
cmake \
ninja \
ccache \
openmpi

# Cleanup
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set the entry point
CMD ["/bin/bash"]
