
FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
# Set the working directory
WORKDIR /workspace

# Install necessary dependencies, including sudo and networking tools
RUN apt-get update && apt-get install -y \
    sudo \
    curl \
    iputils-ping \
    git \
    dnsutils \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Install Miniconda
RUN curl -fsSL https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -o miniconda.sh && \
    bash miniconda.sh -b -p /opt/conda && \
    rm miniconda.sh && \
    /opt/conda/bin/conda init


# Add conda to PATH
ENV PATH="/opt/conda/bin:${PATH}"

# Copy the environment.yml file into the container
COPY pyslds.yml /workspace/pyslds.yml

# Create the Conda environment from the exported environment.yml (which includes Python)
RUN conda env create -f /workspace/pyslds.yml
RUN cd /workspace
SHELL ["conda", "run", "-n", "pyslds", "/bin/bash", "-c"]
RUN echo "conda activate pyslds" >> ~/.bashrc

#1
RUN git clone https://github.com/mattjj/pybasicbayes.git
WORKDIR /workspace/pybasicbayes
RUN python setup.py develop
WORKDIR /workspace

#2
RUN git clone https://github.com/mattjj/pyhsmm.git
WORKDIR /workspace/pyhsmm
RUN python setup.py develop
WORKDIR /workspace

#3
RUN git clone https://github.com/mattjj/pylds.git
WORKDIR /workspace/pylds
RUN sed -i 's/from cyutil cimport/from pylds.cyutil cimport/' pylds/lds_info_messages.pyx \
 && sed -i 's/from cyutil cimport/from pylds.cyutil cimport/' pylds/lds_messages.pyx
RUN python setup.py develop
WORKDIR /workspace

#4
RUN pip install pypolyagamma

#5
RUN git clone https://github.com/mattjj/pyhsmm-autoregressive
WORKDIR /workspace/pyhsmm-autoregressive
# Add Eigen manually
RUN mkdir -p deps && \
    curl -L https://gitlab.com/libeigen/eigen/-/archive/3.4.0/eigen-3.4.0.tar.gz -o deps/Eigen.tar.gz && \
    tar -xzf deps/Eigen.tar.gz -C deps && \
    mv deps/eigen-3.4.0/Eigen deps/Eigen
RUN sed -i -E 's#cdef int nlags *= *\((params\.shape\[2\] *- *affine)\) */ *D *- *1#cdef int nlags = \1 // D - 1#' autoregressive/messages.pyx
RUN python setup.py develop
WORKDIR /workspace

#6
RUN git clone https://github.com/mattjj/pyslds
WORKDIR /workspace/pyslds
RUN python setup.py develop
WORKDIR /workspace

#7
RUN git clone https://github.com/slinderman/recurrent-slds
WORKDIR /workspace/recurrent-slds
RUN python setup.py develop
WORKDIR /workspace

CMD ["bash"]