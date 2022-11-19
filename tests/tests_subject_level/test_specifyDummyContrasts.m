function test_suite = test_specifyDummyContrasts %#ok<*STOUT>
  % (C) Copyright 2022 bidspm developers
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_specifyDummyContrasts_basic()

  contrasts = struct('C', [], 'name', []);
  counter = 0;

  SPM.xX.name = {'Sn(1) fw*bf(1)', ...
                 'Sn(1) sfw*bf(1)', ...
                 'Sn(1) bw*bf(1)', ...
                 'Sn(1) sbw*bf(1)', ...
                 'Sn(1) ld*bf(1)', ...
                 'Sn(1) sld*bf(1)', ...
                 'Sn(1) response*bf(1)', ...
                 'Sn(1) rot_x', ...
                 'Sn(1) rot_y', ...
                 'Sn(1) rot_z', ...
                 'Sn(1) trans_x', ...
                 'Sn(1) trans_y', ...
                 'Sn(1) trans_z', ...
                 'Sn(1) constant'};

  SPM.xX.X = rand(3, numel(SPM.xX.name));

  model_file = fullfile(getDummyDataDir(), 'models', 'model-bug815_smdl.json');
  model = bids.Model('file', model_file, 'verbose', true);

  node.Name = 'subject_level';
  node.DummyContrasts.Test = 't';
  node.Level = 'Subject';
  node.GroupBy = {'contrast', 'subject'};
  node.Model.X = 1;

  [contrasts] = specifyDummyContrasts(contrasts, node, counter, SPM, model);

  assertEqual(numel({contrasts.name}), 7);

end

function test_specifyDummyContrasts_bug_815()

  contrasts = struct('C', [], 'name', []);
  counter = 0;

  SPM.xX.name = {'Sn(1) fw*bf(1)', ...
                 'Sn(1) sfw*bf(1)', ...
                 'Sn(1) bw*bf(1)', ...
                 'Sn(1) sbw*bf(1)', ...
                 'Sn(1) ld*bf(1)', ...
                 'Sn(1) sld*bf(1)', ...
                 'Sn(1) response*bf(1)', ...
                 'Sn(1) rot_x', ...
                 'Sn(1) rot_y', ...
                 'Sn(1) rot_z', ...
                 'Sn(1) trans_x', ...
                 'Sn(1) trans_y', ...
                 'Sn(1) trans_z', ...
                 'Sn(1) constant'};

  SPM.xX.X = rand(3, numel(SPM.xX.name));

  model_file = fullfile(getDummyDataDir(), 'models', 'model-bug815_smdl.json');
  model = bids.Model('file', model_file, 'verbose', true);

  node = model.Nodes{2};

  [contrasts, counter] = specifyDummyContrasts(contrasts, node, counter, SPM, model);

  assertEqual(numel({contrasts.name}), 7);

end