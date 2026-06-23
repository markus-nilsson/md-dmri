function p = elastix_p_6dof(n_iter)
% function p = elastix_p_6dof(n_iter)
%
% Use an affine transform, but with all parameters except 
% translation x, y and rotation around z set to zero

if (nargin < 1), n_iter = 300; end

% ImageTypes
p.FixedInternalImagePixelType           = 'float';
p.FixedImageDimension                   = 3;
p.MovingInternalImagePixelType          = 'float';
p.MovingImageDimension                  = 3;

% Components setup
p.Registration                          = 'MultiResolutionRegistration';
p.FixedImagePyramid                     = 'FixedRecursiveImagePyramid';
p.MovingImagePyramid                    = 'MovingRecursiveImagePyramid';
p.Interpolator                          = 'BSplineInterpolator';
p.Optimizer                             = 'AdaptiveStochasticGradientDescent';
p.ResampleInterpolator                  = 'FinalBSplineInterpolator';
p.Resampler                             = 'DefaultResampler';
p.Transform                             = 'AffineDTITransform';
p.Metric                                = 'AdvancedMattesMutualInformation';

% Et c
p.ErodeMask                             = 'false';
p.HowToCombineTransforms                = 'Compose';
p.AutomaticTransformInitialization      = 'false';
p.AutomaticScalesEstimation             = 'true';
p.DefaultPixelValue                     = 0;

% Output in nifti
p.WriteResultImage                      = 'true';
p.ResultImagePixelType                  = 'float';
p.ResultImageFormat                     = 'nii';
p.CompressResultImage                   = 'false';

% Resolution and sampling
p.NumberOfResolutions                   = 2;
p.MaximumNumberOfIterations             = n_iter; 
p.NumberOfHistogramBins                 = [32 32];
p.ImagePyramicSchedule                  = [2 2 2 1 1 1];
p.ImageSampler                          = 'RandomCoordinate';

p.NewSamplesEveryIteration              = 'true';
p.NumberOfSpatialSamples                = 8192;

% Order of B-Spline interpolation used in each resolution level, final et c
p.BSplineInterpolationOrder             = 1;
p.FinalBSplineInterpolationOrder        = 3;

%  * This transform applies an affine transformation, but is parameterized by
%  * angles, shear factors, scales, and translation, instead of by the affine matrix.
%  * It is meant for registration of MR diffusion weighted images, but could be
%  * used for other images as well of course.
p.Scales = power(10, [3 3 3  9 9 9  9 9 9  0 0 0 ]);

  

         


