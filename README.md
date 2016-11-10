#Multidimensional diffusion MRI 

Multidimensional diffusion MRI (MD-dMRI) is a family of conceptually related methods relying on advanced gradient modulation schemes and data processing approaches to simultaneously quantify several microstructural and dynamical properties of tissue by separating their effects on the detected MRI signal into multiple acquisition and analysis dimensions.

This GitHub repository mainly contains MATLAB software for analysis of MD-dMRI data, and also some auxiliary routines for setup of acquisition protocols, motion correction, and image visualization.

Three families of methods are currently implemented within the framework of MD-dMRI:
* Diffusion tensor distributions
* Diffusional exchange
* Diffusion and incoherent flow

The methods are described briefly [here](../documentation/models/README.md), in some more detail in two review articles,<sup>1,2</sup> and more exhaustively in the original publications cited for each method.

## How to start

Run setup_paths in the root folder to put files in the Matlab path.

Please see readme.txt in each folder for a brief description of all parts,
or http://markus-nilsson.github.io/md-dmri/ for a html-version of those
files.

Check various models by looking into functions named \*_pipe.m under models/\*

Get acquainted with by xps structure by reading mdm/readme.txt.

#References
1. D. Topgaard. Multidimensional diffusion MRI. J. Magn. Reson.,  (2017).
2. D. Topgaard. NMR methods for studying microscopic diffusion anisotropy. In: R. Valiullin (Ed.) Diffusion NMR in confined systems: Fluid transport in porous solids and heterogeneous materials, New Developments in NMR 9, Royal Society of Chemistry, Cambridge, UK (2017).

