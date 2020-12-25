% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function matlabbatch = setBatchImageCalculation(matlabbatch, input, output, outDir, expression)
  %
  % Set a batch for a image calculation
  %
  % USAGE::
  %
  %   matlabbatch = setBatchImageCalculation(matlabbatch, input, output, outDir, expression)
  %
  % :param matlabbatch:
  % :type matlabbatch: structure
  % :param input: list of images
  % :type input: cell
  % :param output: name of the output file
  % :type output: string
  % :param outDir:
  % :type outDir: string
  % :param expression:
  % :type expression: string
  %
  % :returns: - :matlabbatch:
  %

  if ~iscell(input)
    error('The list of images must be in a cell.');
  end

  printBatchName('image calculation');

  matlabbatch{end + 1}.spm.util.imcalc.input = input;
  matlabbatch{end}.spm.util.imcalc.output = output;
  matlabbatch{end}.spm.util.imcalc.outdir = { outDir };
  matlabbatch{end}.spm.util.imcalc.expression = expression;

  % matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
  % matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
  % matlabbatch{1}.spm.util.imcalc.options.mask = 0;
  % matlabbatch{1}.spm.util.imcalc.options.interp = 1;
  % matlabbatch{1}.spm.util.imcalc.options.dtype = 4;

end
