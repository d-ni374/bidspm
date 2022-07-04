function deleteResidualImages(ffxDir)
  %
  % USAGE::
  %
  %   deleteResidualImages(ffxDir)
  %
  % :param ffxDir:
  % :type ffxDir: char
  %
  % (C) Copyright 2020 CPP_SPM developers

  delete(fullfile(ffxDir, 'Res_*.nii'));
  delete(fullfile(ffxDir, 'res4d.nii*'));

end
