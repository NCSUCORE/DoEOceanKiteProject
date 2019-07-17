zenith = 90-elevation;

set_param([gcb,'/VR Sink'],'SampleTime',num2str(animSampleTime));
set_param([gcb,'/VR Sink'],'VideoDimensions',['[' num2str(round(vidDims(1))) ' ' num2str(round(vidDims(2))) ']']);

% vrSinkBlockPath   = [gcb,'/VR Sink'];
% vrSinkBlockHandle = getSimulinkBlockHandle(vrSinkBlockPath);
% prtCon            = get_param(vrSinkBlockHandle,'PortConnectivity');
% objParams         = get_param(prtCon(end).DstBlock,'ObjectParameters');
% isFileOutBlock    = isfield(objParams,'outputFilename');
% 
% oldBlock = prtCon(end).DstBlock;
% 
% if vidLogEnbl
%     newBlock = 'dspvision/To Multimedia File';
% else
%     newBlock = 'Simulink/Sinks/Terminator';
% end
% oldType = get_param(oldBlock,'BlockType');
% newType = get_param(newBlock,'ObjectParameters');