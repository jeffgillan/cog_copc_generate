FROM ubuntu:22.04

# Set environment variables to non-interactive
ENV DEBIAN_FRONTEND=noninteractive

# Install Miniconda dependencies
RUN apt-get update && apt-get install -y \
    wget \
    bzip2 \
    ca-certificates \
    libglib2.0-0 \
    libxext6 \
    libsm6 \
    libxrender1 \
    git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Miniconda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh && \
    /bin/bash /tmp/miniconda.sh -b -p /opt/conda && \
    rm /tmp/miniconda.sh

# Set PATH to include conda
ENV PATH=/opt/conda/bin:$PATH

# Create a new conda environment and install untwine
RUN conda create -n untwine_env -c conda-forge untwine=1.0.0 && \
    conda install -c conda-forge gdal && \
    conda clean -afy

# Set PATH to include conda
ENV PATH=/opt/conda/envs/untwine_env/bin:$PATH

# Set the PROJ_LIB environment variable
ENV PROJ_LIB=/opt/conda/envs/untwine_env/share/proj

# Activate the environment
SHELL ["conda", "run", "-n", "untwine_env", "/bin/bash", "-c"]

# Copy your shell script into the container
COPY laz_to_copc.sh /usr/local/bin/laz_to_copc.sh

# Make the shell script executable
RUN chmod +x /usr/local/bin/laz_to_copc.sh

# Set the entrypoint to your shell script
ENTRYPOINT ["/usr/local/bin/laz_to_copc.sh"]