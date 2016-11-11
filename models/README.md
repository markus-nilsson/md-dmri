#MD-dMRI methods

Three families of methods are currently implemented within the framework of MD-dMRI:
* [Diffusion tensor distributions](#diffusion-tensor-distributions)
* [Diffusional exchange](#diffusional-exchange)
* [Diffusion and incoherent flow](#diffusion-and-incoherent-flow)

The methods are described briefly below, in some more detail in two review articles,<sup>1,2</sup> and more exhaustively in the original publications cited for each method. Before a mathematically and physically correct description of the methods and the parameters that can be obtained, we start with a more hand-waving line of reasoning intended for a non-expert reader that has previous experience of conventional dMRI. The following text assumes familiarity with standard dMRI terminology such as diffusion tensors, diffusion anisotropy, kurtosis, orientation distributions functions, and intravoxel incoherent motion, as well as the commonly used acronyms DTI, MD, FA, and DKI.<sup>3-6</sup>

The description of the methods is followed by some [details about our Matlab code](#implementation-details) for generating MD-dMRI parameter maps.

## Diffusion tensor distributions
The microscopic geometry of tissue is imprinted in the sizes, shapes, and orientations of the water diffusion tensors that are measured with dMRI. Conventional methods give diffusion tensors that are averaged over all the microscopic water environments within the millimeter-size imaging voxels, thereby giving ambiguous information for heterogeneous tissue which is ubiquitous in the human brain. Our MD-dMRI methods have the capability to disentangle the effects of microscopic diffusion tensor sizes, shapes, and orientations, allowing for detailed tissue characterization in terms of well-defined statistical measures of the diffusion tensor distributions. These measures have simple and intuitive relations to tissue properties such as average cell shape and variability of cell density.

The diffusion tensor distribution (DTD) model relies on the assumption that the water molecules within a voxel can be subdivided into groups exhibiting anisotropic Gaussian diffusion as quantified by a microscopic diffusion tensor **D**, which can be reported as a 3x3 matrix and visualized as an ellipsoid with semi-axis lengths and directions given by the tensor eigenvalues and eigenvectors. Somewhat colloquially, a diffusion tensor is characterized by its size, shape, and orientation, which are properties that are given by the chemical composition and micrometer-scale geometry of the pore space in which the water is located. The terms size, shape, and orientation can also be applied to the cells in the tissue region being investigated, but in the following text we will use them for the tensors. The relations between diffusion tensors and the microscopic properties of cells are investigated in some detail in the dMRI literature.

![Image](DTD_2Spheres2Sticks.png)

The figure above is a schematic illustration of a heterogeneous voxel as a collection of microscopic diffusion tensors, each representing a group of water molecules. While conventional DTI and DKI yield parameters where the information about the sizes, shapes, and orientations of the tensors within a voxel are inextricably entangled, the DTD models are designed to give “clean” size, shape, and orientation measures that are intuitively related to conclusions that can be drawn by simply looking at a schematic picture with a collection of tensors. For the voxel above, we can observe four types of tensors: two spherical ones having different sizes as well as two nearly linear ones with identical sizes and shapes, but different orientations. Within the approximation of the DTD model, the most complete description of the voxel would be a list of sizes, shapes, orientations, and fractional populations of the microscopic tensors, or, alternatively, a continuous probability distribution _P_(**D**). Such a complete description is challenging to obtain, but actually possible with sufficient access to scanner time. Less challenging is to give up the attempts at finding separate components in the distribution and instead focus on scalar measures quantifying means and variances of the size, shape, and orientation properties. The utility of such an approach is illustrated with the three examples below that are indistinguishable with conventional DTI – the voxel-average diffusion tensor <**D**> and the derived parameters MD and FA would be exactly the same.

![Image](DTD_3Examples.png)

The voxel to the left comprises identical prolate tensors with the same orientation, and the middle example contains nearly linear tensors with three different orientations. While the tensors of the left and middle cases have the same sizes, they differ with respect to shapes and orientations. The example to the right is more complex with three distinct tensors: small and large spheres as well as linear tensors with intermediate size. In order to distinguish the three cases, we need at least three scalar measures, for instance the variance of sizes, the average shape, and the orientational order parameter. All examples have the same average sizes, and, although not immediately obvious, the left and right examples have identical average shapes and order parameters. The left and middle cases can be distinguished from both their different average shapes and order parameters, while the unique property of the example to the right is its variance of both sizes and shapes.

### Parameterization of the diffusion tensor
In the text above, we have described the diffusion tensors with the terms size, shape, and orientation without including proper definitions. A general diffusion tensor **D** contains six independent elements and can be parameterized according to several different conventions.<sup>2</sup> Imposing the constraint that the microscopic tensors are axisymmetric, the number of independent elements is reduced to four. Rather than reporting explicit tensor elements, it is more intuitive to parameterize the tensor in terms of the isotropic average _D_<sub>iso</sub>, the normalized anisotropy _D_<sub>Delta</sub>, as well as the polar and azimuthal angles phi and theta specifying the orientation of the main symmetry axis in the lab frame.<sup>7</sup> The parameters _D_<sub>iso</sub> and _D_<sub>Delta</sub> are quantitative measures of, respectively, the sizes and shapes of the tensors in the figures above. The values of _D_<sub>Delta</sub> cover the range from –1/2 for planes, to 0 for spheres, and +1 for sticks.

### Four-, two-, and one-dimensional projections of the DTD
The general six-dimensional DTD _P_(**D**) can for the axisymmetric case be written as the four-dimensional distribution _P_(_D_<sub>iso</sub>,_D_<sub>Delta</sub>,theta,phi) with clear separation of the size, shape, and orientation properties in individual dimensions. Integrating _P_(_D_<sub>iso</sub>,_D_<sub>Delta</sub>,theta,phi) over the orientation dimensions gives the two-dimensional size-shape distribution _P_(_D_<sub>iso</sub>,_D_<sub>Delta</sub>), which upon integration over the shape dimension leaves the one-dimensional size distribution _P_(_D_<sub>iso</sub>).

### Scalar parameters describing the DTD
We have defined scalar metrics quantifying means and variances of the size, shape, and orientation dimensions of the DTD. Because of the different research areas and intended readers of the original articles, these metrics have been introduced under several names, symbols, and types of normalization, and for a newcomer to the field it is not immediately obvious that they contain essentially the same information. A compilation of the introduced symbols can be found in this [pdf](../models/DTDmetrics.pdf).

### DTD Methods
The MD-dMRI methods for quantifying DTDs can be classified according to the obtained level of detail for which each of the size, shape, and orientation dimensions are investigated. The MD-dMRI methods currently included in this repository are:

| Name | reference | size| shape | orientation| algorithm |
| ---:|:---:|:---:|:---:|:---:|:----:|
| dtd_full | Topgaard 2017<sup>1</sup> | distribution | distribution | distribution | NNLS |
| dtd_saupe | Topgaard 2016<sup>8</sup> | 1 component | 1 component | order tensor | NLSQ |
| dtd_covariance | Westin 2016<sup>9</sup> |  mean and variance | mean and variance | order parameter | LLSQ |
| dtd_gamma | Lasič 2014<sup>10</sup> |  mean and variance | mean | order parameter | NLSQ |
| dtd_pa | Martins 2016<sup>11</sup> | distribution | distribution | - | NNLS |
| dtd_codivide | Lampinen2 | 3 components | 3 components | - | NLSQ |
| dtd_ndi | Lampinen1| 3 components | 3 components | - | NLSQ |
| dtd_pake | Eriksson 2015<sup>7</sup> | 1 component | 1 component | - | NLSQ |
NNLS: non-negative least squares; NLSQ: nonlinear least squares; LLSQ: linear least squares.


## Diffusional exchange
The plasma membrane separates the intracellular space from the surroundings and is an efficient barrier for water. The permeability of the membrane is affected by its chemical composition and the presence of channel proteins such as aquaporins. We have developed a MD-dMRI method to quantify the rate of molecular exchange between microscopic tissue environments with different local water diffusivity.<sup>12</sup> The exchange rate is influenced by the barrier properties of the membrane and can for simple cellular systems be converted to a quantitative measure of the membrane permeability.<sup>13</sup>

Name: fexi11. Reference: Lasič 2011.<sup>12</sup>

## Diffusion and incoherent flow
Water in tissue and flowing in the capillary network have distinctly different patterns of translational motion. Our MD-dMRI method relies on motion encoding with variable sensitivity to flow and diffusion to quantify the density of blood capillaries.<sup>14</sup>

Name: vasco16. Reference: Ahlgren 2016.<sup>14</sup>

# Implementation details

All functions that concern a specific method are located in methods/name (folder currently named 'models' will be renamed to 'methods'). 
In that folder, a specific set of functions must be present that conforms to the following structure of the function call

```matlab
m = name_1d_data2fit(signal, xps, opt, ind)
```

Purpose: Fits a model to a signal. Input arguments are an 1D vector with signal values (```signal```), the 
experimental parameter structure xps (`xps`, see below), an option structure (`opt`) generated by `name_opt`, 
and an index vector `ind` that potentially subselects signal values. Output argument is a 1D vector with 
fitted model parameters (`m`), where the first should relate to the overall signal intensity.

```matlab
signal = name_1d_fit2data(m, xps)
```

Purpose: Predicts the signal. Input parameters are the model parameter vector, and the experimental parameter structure (`xps`). Output is the predicted signal vector (`signal`).


```matlab
mfs_fn = name_4d_data2fit(s, mfs_fn, opt)
```

Purpose: Fits a model to all data points. Input parameters are an input structure (`s`, see below), a model fit structure filename (`mfs_fn`), and an options structure (`opt`).


```matlab
dps = name_4d_fit2datam(mfs_fn, dps_fn, opt)
```

Purpose: Converts fitted model parameters to derived parameters (e.g. from fitted diffusion tensor elements to the fractional anisotropy). Input parameters are a model fit structure filename (`mfs_fn`), a derived parameter filename (`dps_fn`), and an options structure (`opt`). Output is the derived parameter structure.


```matlab
name_check_xps(xps)
```

Purpose: Check that the `xps` contains all required fields.

```matlab
name_opt(opt)
```

Purpose: Adds necessary fields to the `opt` structure, but should not overwrite existing fields.


```matlab
name_plot(signal, xps, h, h2)
```

Purpose: Fits data and displays a plot. Input parameters are a signal vector (`signal`), an experimental parameter structure (`xps`), and two figure handles (`h` and `h2`). 

## Experimental parameter and input structures
The experimental parameter structure (`xps`) contains fields that describe the experiment, for example, the b-value and the b-tensors. The input structure (`s`) contains references to a nifti file, potentially a mask, and the xps. More information is found at http://markus-nilsson.github.io/md-dmri/#p3

# References
1. D. Topgaard. Multidimensional diffusion MRI. J. Magn. Reson.,  (2017).
2. D. Topgaard. NMR methods for studying microscopic diffusion anisotropy. In: R. Valiullin (Ed.) Diffusion NMR in confined systems: Fluid transport in porous solids and heterogeneous materials, New Developments in NMR 9, Royal Society of Chemistry, Cambridge, UK (2017).
3. D. Le Bihan, E. Breton, D. Lallemand, P. Grenier, E. Cabanis, M. Laval-Jeantet. MR imaging of intravoxel incoherent motions - application to diffusion and perfusion in neurological disorders. Radiology 161, 401-407 (1986).
4. P.J. Basser, J. Mattiello, D. Le Bihan. Estimation of the effective self-diffusion tensor from the NMR spin echo. J. Magn. Reson. B 193, 247-254 (1994).
5. P.J. Basser, C. Pierpaoli. Microstructural and physiological features of tissues elucidated by quantitative-diffusion-tensor MRI. J. Magn. Reson. B 111, 209-219 (1996).
6. J.H. Jensen, J.A. Helpern, A. Ramani, H. Lu, K. Kaczynski. Diffusional kurtosis imaging: The quantification of non-Gaussian water diffusion by means of magnetic resonance imaging. Magn. Reson. Med. 53, 1432-1440 (2005).
7. S. Eriksson, S. Lasič, M. Nilsson, C.-F. Westin, D. Topgaard. NMR diffusion encoding with axial symmetry and variable anisotropy: Distinguishing between prolate and oblate microscopic diffusion tensors with unknown orientation distribution. J. Chem. Phys. 142, 104201 (2015).
8. D. Topgaard. Director orientations in lyotropic liquid crystals: Diffusion MRI mapping of the Saupe order tensor. Phys. Chem. Chem. Phys. 18, 8545-8553 (2016).
9. C.-F. Westin, H. Knutsson, O. Pasternak, F. Szczepankiewicz, E. Özarslan, D. van Westen, C. Mattisson, M. Bogren, L. O'Donnell, M. Kubicki, D. Topgaard, M. Nilsson. Q-space trajectory imaging for multidimensional diffusion MRI of the human brain. Neuroimage 135, 345-362 (2016).
10. S. Lasič, F. Szczepankiewicz, S. Eriksson, M. Nilsson, D. Topgaard. Microanisotropy imaging: quantification of microscopic diffusion anisotropy and orientational order parameter by diffusion MRI with magic-angle spinning of the q-vector. Front. Physics 2, 11 (2014).
11. J.P. de Almeida Martins, D. Topgaard. Two-dimensional correlation of isotropic and directional diffusion using NMR. Phys. Rev. Lett. 116, 087601 (2016).
12. S. Lasič, M. Nilsson, J. Lätt, F. Ståhlberg, D. Topgaard. Apparent exchange rate (AXR) mapping with diffusion MRI. Magn. Reson. Med. 66, 356-365 (2011).
13. I. Åslund, A. Nowacka, M. Nilsson, D. Topgaard. Filter-exchange PGSE NMR determination of cell membrane permeability. J. Magn. Reson. 200, 291-295 (2009).
14. A. Ahlgren, L. Knutsson, R. Wirestam, M. Nilsson, F. Ståhlberg, D. Topgaard, S. Lasič. Quantification of microcirculatory parameters by joint analysis of flow-compensated and non-flow-compensated intravoxel incoherent motion (IVIM) data. NMR Biomed. 29, 640-649 (2016).

