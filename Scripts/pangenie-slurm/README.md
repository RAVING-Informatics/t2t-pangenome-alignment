# Installation
1. Clone the github repository onto Setonix
2. Build the singularity container on Nimbus (need sudo access)
`sudo singularity build pangenie.sif pangenie.def`
3. Transfer the built container to Setonix
4. Test install
`singularity exec pangenie.sif PanGenie --help`
