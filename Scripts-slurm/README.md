Installation
Clone the github repository onto Setonix
Build the singularity container on Nimbus (need sudo access)
sudo singularity build pangenie.sif pangenie.def
Transfer the built container to Setonix
singularity exec pangenie.sif PanGenie --help
