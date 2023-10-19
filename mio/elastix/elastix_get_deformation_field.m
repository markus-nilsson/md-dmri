function T = elastix_get_deformation_field(t)

tmp_path = msf_tmp_path(1);

t_fn = fullfile(tmp_path, 't.txt');

elastix_p_write(t, t_fn);

msf_system(sprintf('transformix -def all -out %s -tp %s', tmp_path, t_fn));

T = mdm_nii_read(fullfile(tmp_path, 'deformationField.nii'));
