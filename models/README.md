#Models for Multidimensional Diffusion MRI

Multidimensional dMRI is a family of methods using advanced gradient modulation schemes and data processing to simultaneously quantify several microstructural and dynamical parameters by separating their effects on the detected MRI signal in multiple acquisition and analysis dimensions.

Three families of models are currently implemented within the framework:
* Diffusion tensor distributions
* Diffusional exchange
* Diffusion and incoherent flow

The models are described briefly below, in some more detail in two review articles,<sup>1,2</sup> and more completely in the original publications cited for each model. The description assumes familiarity with conventional dMRI terminology, such as diffusion tensor, diffusion anisotropy, kurtosis, orientation distributions function, and intravoxel incoherent motion, as well as the commonly used acronyms DTI, FA, DKI.<sup>3-6</sup>

##Diffusion tensor distributions
The diffusion tensor distribution (DTD) model relies on the assumption that the water molecules within a voxel can be grouped into sub-ensembles exhibiting anisotropic Gaussian diffusion as quantified by a microscopic diffusion tensor **D**, which can be reported as a 3x3 matrix and visualized as an ellipsoid or a superquadric with semi-axis lengths and directions given by the tensor eigenvalues and eigenvectors. Somewhat colloquially, a diffusion tensor is characterized by its size, shape, and orientation, which are properties that are given by the chemical composition and micrometer-scale geometry of the pore space in which the water is located.

![Image](DTD_2Spheres2Sticks.png)

The figure above is a schematic illustration of a heterogeneous voxel as a collection of microscopic diffusion tensors, each representing a sub-ensemble of water molecules. While conventional DTI and DKI yield parameters where the information about the sizes, shapes, and orientations of the members of the collections are inextricably entangled, the DTD models are designed to give “clean” size, shape, and orientation measures that are intuitively related to conclusions that can be drawn by simply looking at a picture with a schematic ensembles. For the voxel above, we can observe four types of microscopic tensors: two spherical ones having different sizes as well as two nearly linear ones with identical sizes and shapes, but different orientations. Within the approximation of the DTD model, the most complete description of the voxel would be a list of sizes, shapes, orientations, and fractional populations of the microscopic tensors, or, alternatively, a continuous probability distribution _P_(**D**). Such a complete description is challenging to obtain, but actually possible with sufficient access to scanner time. Less challenging is to give up the attempts at finding separate components in the distribution and instead focus on scalar measures quantifying means and variances of the size, shape, and orientation properties. The utility of such an approach is illustrated with the examples below that would all give the same voxel-average diffusion tensor in conventional DTI.

![Image](DTD_3Examples.png)

The ensemble to the left comprises identical prolate tensors with the same orientations, and the middle example contains nearly linear tensors with three different orientations. While the tensors of the left and middle examples have the same sizes, they differ with respect to shapes and orientations. The example to the right is more complex with three distinct tensors: small and large spheres as well as linear tensors with intermediate size. In order to distinguish the three cases, we need at least three scalar measures, for instance the variance of sizes, the average shape, and the orientational order parameter. All examples have the same average sizes, and, although not immediately obvious, the left and right examples have identical average shapes and order parameters. The left and middle cases can be distinguished from both their different average shapes and order parameters, while the unique property of the example to the right is its variance of both sizes and shapes.

###size-shape-orientation 
* dtd_6d_full, integral transform, lsqnonneg shotgun
* dtd_4d_full, integral transform, lsqnonneg shotgun
* dtd_qti, 2-term cumulant <**D**> **C**, \
* dtd_dti, 1-term cumulant <**D**>, \

###size-shape
* dtd_pa_full, integral transform, lsqnonneg shotgun
* dtd_pa_cum2, 2-term cumulant <_D_<sub>iso</sub>>, V(_D_<sub>iso</sub>), lsqcurvefit
* dtd_pa_gamma, gamma, lsqcurvefit
* dtd_pa_codivide, constrained 3 comp, lsqcurvefit
* dtd_pa_ndi, constrained 2 comp, lsqcurvefit
* dtd_pa_pake, 1 comp, lsqcurvefit

###size
* dtd_iso_full, integral transform, lsqnonneg shotgun
* dtd_iso_gamma, gamma, lsqcurvefit
* dtd_iso_exp, exp, lsqcurvefit


##Diffusional exchange
fexi11

##Diffusion and incoherent flow
vasco16

#References
1. D. Topgaard. NMR methods for studying microscopic diffusion anisotropy. In: R. Valiullin (Ed.) Diffusion NMR in confined systems: Fluid transport in porous solids and heterogeneous materials, New Developments in NMR 9, Royal Society of Chemistry, Cambridge, UK (2017).
2. D. Topgaard. Multidimensional diffusion MRI. J. Magn. Reson.,  (2017).
3. D. Le Bihan, E. Breton, D. Lallemand, P. Grenier, E. Cabanis, M. Laval-Jeantet. MR imaging of intravoxel incoherent motions - application to diffusion and perfusion in neurological disorders. Radiology 161, 401-407 (1986).
4. P.J. Basser, J. Mattiello, D. Le Bihan. Estimation of the effective self-diffusion tensor from the NMR spin echo. J. Magn. Reson. B 193, 247-254 (1994).
5. P.J. Basser, C. Pierpaoli. Microstructural and physiological features of tissues elucidated by quantitative-diffusion-tensor MRI. J. Magn. Reson. B 111, 209-219 (1996).
6. J.H. Jensen, J.A. Helpern, A. Ramani, H. Lu, K. Kaczynski. Diffusional kurtosis imaging: The quantification of non-Gaussian water diffusion by means of magnetic resonance imaging. Magn. Reson. Med. 53, 1432-1440 (2005).

