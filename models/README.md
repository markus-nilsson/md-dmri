#Models for Multidimensional Diffusion MRI

Multidimensional dMRI is a family of methods using advanced gradient modulation schemes and data processing to simultaneously quantify several microstructural and dynamical parameters by separating their effects on the detected MRI signal in multiple acquisition and analysis dimensions.

Three families of models are currently implemented within the framework:
* Diffusion tensor distributions
* Diffusional exchange
* Diffusion and incoherent flow

The models are described briefly below, in some more detail in two review articles,<sup>1,2</sup> and more completely in the original publications cited for each model. The description assumes familiarity with conventional dMRI terminology, such as diffusion tensors, diffusion anisotropy, orientation distributions functions, intavoxel incoherent motion, etc.

##Diffusion tensor distributions
The diffusion tensor distribution (DTD) model relies on the assumption that the water molecules within a voxel can be separated into sub-ensembles exhibiting anisotropic Gaussian diffusion. The diffusion of each sub-ensemble is given by a microscopic diffusion tensor **D**.
![Image](DTD_2Spheres2Sticks.png)
and the composition of a voxel is reported with a probability distribution _P_(**D**).

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
