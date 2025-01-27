# cog_copc_generate

This repository describes the use of containerized software to **1.** convert geotif files to cloud-optimized geotifs (COGs) and **2.** convert.laz (or .las) point clouds to cloud-optimized point clouds (COPCs). The conversion to COGs is executed using [Gdal](https://gdal.org/en/stable/) command-line tool, while the conversion to COPCs is handled by [Untwine](https://github.com/hobuinc/untwine) command-line tool. 

Gdal and Untwine are containerized using `docker`. The container image is hosted on Dockerhub [here](https://hub.docker.com/repository/docker/jeffgillan/cog_copc_generate/general).

<br>
<br>

## Run the Container Image

When you run the container image, it will crawl over a user defined volume and convert all the geotifs to COGs and all .laz/.las point clouds to COPCs. The new files will be written to the same input directory. 

<br>

`docker run --rm -v <directory/with/cogs/copc>:/input jeffgillan/cog_copc_generate:amd64`

<br>
<br>

## Pair cog_copc_generate with automate-metashape

This `cog_copc_generate` container was designed to work direcly with [automate-metashape](https://github.com/open-forest-observatory/automate-metashape) created by [Open Forest Observatory](https://openforestobservatory.org/). Before using `cog_copc_generate` with `automate-metashape`, it is best to first familiarize yourself with how to use the containerized implimentation of automate-metashape [here](https://github.com/open-forest-observatory/automate-metashape?tab=readme-ov-file#setup-docker-container). 

`Automate-metashape` and `cog_copc_generate` are both in docker containers. We can run them sequentially using `docker compose`. `Automate-metashape` will run first and output imagery products into a user-defined directory. `cog_copc_generate` will wait for the first container to run and then proceed to crawl throught the output directory and convert all geotifs to COGs, and all .laz/las to COPCs. 

### Setup with docker-compose.yml

Configuration to run `automate-metashape` and `cog_copc_generate` sequentially is controlled in the `docker-compose.yml` file located in this repository. Download this file to be in or near the local directory with the aerial images to be processed. You only need to change a few items in this yml. 

* Specify the directory of images to be mounted in the container. This is relative to your current working directory. 
* Make sure your Metashape license has already been declared in your terminal session
* Specify the directory where the output image products are being written to. This is relative to your current working directory and is specified within the automate-metashape `config.yml`. Please **do not** change the location of the mounted directory in the container (ie, `/input`).

<br>

```
services:
  automate-metashape:
    image: ghcr.io/open-forest-observatory/automate-metashape
    container_name: automate-metashape
    volumes:
      - "</host/data/dir>:/data" ### Directory of images to be mounted in the container (relative to your current working directory) 
    environment:
      - AGISOFT_FLS=${AGISOFT_FLS} ### You should have declared your Metashape license in the terminal already
    
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: all
              capabilities: [gpu]

  untwine:
    image: jeffgillan/cog_copc_generate:amd64
    container_name: cog_copc_generate
    depends_on:
      automate-metashape:
        condition: service_completed_successfully
    volumes:
      - ../output:/input  ### Directory where image products are written to (relative to your current working directory)
```


### Run docker compose

At the terminal, you need to be located in the directory where the `docker-compose.yml` is located.

`docker compose up`


