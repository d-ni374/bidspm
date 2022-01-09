function functionalQA(opt)
  %
  % For functional data, QA consists in getting temporal SNR and then
  % check for motion - here we also compute additional regressors to
  % account for motion.
  %
  % USAGE::
  %
  %   functionalQA(opt)
  %
  % :param opt: Options chosen for the analysis. See ``checkOptions()``.
  % :type opt: structure
  %
  % ASSUMPTIONS:
  %
  % The previous step must have already been run:
  %
  %   - the functional images have been realigned and resliced using etiher
  %     ``bidsSpatialPrepro()``, ``bidsRealignUnwarp()``, ``bidsRealignReslice()``
  %   - the quality analysis of the anatomical data has been done with ``anatomicalQA()``
  %   - the tissue probability maps have been generated in the "native" space of each subject
  %     (using ``bidsSpatialPrepro()`` or ``bidsSegmentSkullStrip()``) and have been
  %     resliced to the dimension of the functional with ``bidsResliceTpmToFunc()``
  %
  % (C) Copyright 2020 CPP_SPM developers

  if isOctave()
    warning('\nfunctionalQA is not yet supported on Octave. This step will be skipped.');
    return
  end

  opt.dir.input = opt.dir.preproc;

  [BIDS, opt] = setUpWorkflow(opt, 'quality control: anatomical');

  for iSub = 1:numel(opt.subjects)

    subLabel = opt.subjects{iSub};

    printProcessingSubject(iSub, subLabel, opt);

    % get grey and white matter and csf tissue probability maps
    res = 'bold';
    space = 'individual';
    [greyMatter, whiteMatter, csf] = getTpmFilenames(BIDS, subLabel, res, space);
    tpms = char({greyMatter; whiteMatter; csf});

    % load metrics from anat QA
    anatQaMetrics = bids.query('data', query, 'suffix', 'qametrics');
    anatQA = spm_jsonread(anatQaMetrics);

    [sessions, nbSessions] = getInfo(BIDS, subLabel, opt, 'Sessions');

    for iSes = 1:nbSessions

      % get all runs for that subject across all sessions
      [runs, nbRuns] = getInfo(BIDS, subLabel, opt, 'Runs', sessions{iSes});

      for iRun = 1:nbRuns

        % get the filename for this bold run for this task
        [fileName, subFuncDataDir] = getBoldFilename( ...
                                                     BIDS, ...
                                                     subLabel, ...
                                                     sessions{iSes}, ...
                                                     runs{iRun}, ...
                                                     opt);

        funcImage = validationInputFile(subFuncDataDir, fileName, prefix);

        % sanity check that all images are in the same space.
        volumesToCheck = {funcImage; greyMatter; whiteMatter; csf};
        spm_check_orientations(spm_vol(char(volumesToCheck)));

        funcQA = computeFuncQAMetrics(funcImage, tpms, anatQA.avgDistToSurf, opt);

        % TODO find an ouput format that is leaner than a 3 Gb json file!!!
        %           spm_jsonwrite( ...
        %                         fullfile( ...
        %                                  subFuncDataDir, ...
        %                                  strrep(fileName, '.nii',  '_qa.json')), ...
        %                         funcQA, ...
        %                         struct('indent', '   '));
        %           save( ...
        %                fullfile( ...
        %                         subFuncDataDir, ...
        %                         strrep(fileName, '.nii',  '_qa.mat')), ...
        %                'funcQA');

        outputFiles = spmup_first_level_qa( ...
                                           funcImage, ...
                                           'MotionParameters', opt.QA.func.Motion, ...
                                           'FramewiseDisplacement', opt.QA.func.FD, ...
                                           'Globals', opt.QA.func.Globals, ...
                                           'Movie', opt.QA.func.Movie, ...
                                           'Basics', opt.QA.func.Basics, ...
                                           'Voltera', opt.QA.func.Voltera, ...
                                           'Radius', anatQA.avgDistToSurf);

        p = bids.internal.parse_filename(funcImage);
        p.entities.label = p.suffix;
        p.suffix = 'qa';
        p.ext = '.pdf';
        bidsFile = bids.File(p);

        movefile( ...
                 fullfile(subFuncDataDir, 'spmup_QC.ps'), ...
                 spm_file(funcImage, 'filename', bidsFile.filename));

        confounds = load(outputFiles.design);

        p = bids.internal.parse_filename(funcImage);
        p.entities.desc = 'confounds';
        p.suffix = 'regressors';
        p.ext = '.tsv';
        bidsFile = bids.File(p);

        spm_save(spm_file(funcImage, 'filename', bidsFile.filename), ...
                 confounds);

        delete(outputFiles.design);

        createDataDictionary(subFuncDataDir, fileName, size(confounds, 2));

        % create carpet plot

        % horrible hack to prevent the "abrupt" way spmup_volumecorr crashes
        % if nansum is not there
        if opt.QA.func.carpetPlot && exist('nansum', 'file') == 2
          spmup_timeseriesplot(funcImage, greyMatter, whiteMatter, csf, ...
                               'motion', 'on', ...
                               'nuisances', 'on', ...
                               'correlation', 'on', ...
                               'makefig', 'on');
        end

      end

    end

  end

end

function funcQA = computeFuncQAMetrics(funcImage, tpms, avgDistToSurf, opt)

  [subFuncDataDir, fileName, ext] = spm_fileparts(funcImage);

  funcQA.tSNR = spmup_temporalSNR( ...
                                  funcImage, ...
                                  {tpms(1, :); tpms(2, :); tpms(3, :)}, ...
                                  'save');

  realignParamFile = getRealignParamFilename(fullfile(subFuncDataDir, [fileName, ext]), prefix);
  funcQA.meanFD = mean(spmup_FD(realignParamFile, avgDistToSurf));

end
