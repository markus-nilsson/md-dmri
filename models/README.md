#Models for Multidimensional Diffusion MRI

##Diffusion tensor distributions

###size-shape-orientation 
dtd_6d_full, integral transform, lsqnonneg shotgun
dtd_4d_full, integral transform, lsqnonneg shotgun
dtd_qti, 2-term cumulant <**D**> **C**, \
dtd_dti, 1-term cumulant <**D**>, \

###size-shape
dtd_pa_full, integral transform, lsqnonneg shotgun
dtd_pa_gamma, gamma, lsqcurvefit
dtd_pa_codivide, constrained 3 comp, lsqcurvefit
dtd_pa_ndi, constrained 2 comp, lsqcurvefit
dtd_pa_pake, 1 comp, lsqcurvefit

###size
dtd_iso_full, integral transform, lsqnonneg shotgun
dtd_iso_gamma, gamma, lsqcurvefit
dtd_iso_exp, exp, lsqcurvefit


##Exchange
fexi11

##Microcapillary blood flow
vasco16
