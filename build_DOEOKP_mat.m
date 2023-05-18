% build_DOEOKP_mat: needs to run once to write .mat files that are used by various scripts; reduces download size vs. including at files directly
path_DOEOKP=genpath('.');
addpath(path_DOEOKP);

if 1
pathFollowingTether_bs
constT_XYZvarZ_Ramp_bs
constXYZT_bs
ayazAirborneFlow_bs
constYZTvarX_bs
hurricaneSandyWave_bs
steppedLateralFlow_bs
ayazSynFlow_bs
gpkfPathOpt_bs% depends on ayazSynFlow_bs
fullCycleCtrl_bs
guidanceLawPathFollowingAir_bs
guidanceLawPathFollowingWater_bs
pathFollowingCtrlAddedMass_bs
pathFollowingCtrlForILC_bs
ayazPathFollowingAirborne_bs
pathFollowCtrlExp_bs
pathFollowWithAoACtrlDOE_bs
pathFollowingCtrlForILCAoA_bs
newSpoolCtrlExp_bs
periodicCtrlExp_bs
exp_slCtrl_bs
baselineSteadyLevelFlight_bs
firstBuildTakeoff1_bs
firstBuildTakeoff_bs
jamesMultiCycleExp_bs
joshMultiCycleExp_bs
newSpoolCtrl_bs
srgSwyHvCtrl_bs
motionlessGliderCtrl_bs
oneDoFGSCtrlBasic_bs
constBoothLem_bs
constEllipse_bs
basicILCThrTen_bs
basicILC_bs
fig8ILC15mPs_bs
fig8ILC1mPs_bs
fig8ILC2mPs_bs
seILC_bs
varGeom_bs
varAltitudeBooth_bs
varRadiusBooth_bs
ayazThreeTetGndStn_bs
oneThrGndStn000_bs
pathFollowingGndStn_bs
threeThrGndStn000_bs
oneThrThreeAnchGndStn001_bs
oneThrThreeAnchGndStn001_bs
gsWave_bs
raftGroundStation_bs
ayazAirborneThr_bs
ayazFullScaleOneThrTether_bs
ayazThreeTetTethers_bs
fiveNodeSingleTether_bs
ObsTether_bs
shortTether_bs
shortTetherCompare_bs
pathFollowingTetherFaired_bs
fullScale1thr_bs
anchWnch_bs
oneDOFWnch_bs
oneWnch_bs
threeWnch_bs
oneDOFWnchPTO_bs
idealSensorProcessing_bs
realisticSensorProcessing_bs
deadRecPos_bs
idealSensors_bs
lasPosEst_bs
realisticSensors_bs
slCtrl_bs
resizedKiteGndStn_bs% dep on fullScale1thr_bs
poolScaleKite_bs% dependent on dsgnMassFile.mass
ayazFullScaleOneThrWinch_bs
ayazThreeTetWnch_bs
ayazThreeTetCtrl_bs% depends on ayazThreeTetWnch_bs
realisticAirborneVhcl_bs% Unrecognized method, property, or field 'setMass' for class 'OCT.turb'
poolScaleKiteAbney_bs% dependent on 'SG6040_AR7dot4_EXPT.mat'
end

if 0
CNAPsMitchell_bs% depends on pathFollowingTether_bs; error line 8
CNAPsTurbJames_bs% depends on pathFollowingTether_bs; error line 9
DARPATurbJames_bs% depends on pathFollowingTether_bs; error line 10
CNAPsNoTurbJosh_bs% depends on pathFollowingTether_bs; error line 10
CNAPsTurbMitchell_bs% depends on pathFollowingTether_bs; error line 10
end
% poolScaleKiteAbneyDragScreens_bs% dependent on 'SG6040_AR7dot4_EXPT.mat' and poolKiteWingsDragScreen.mat'.
% poolScaleKiteAbneyRefined_bs% dependent on 'SG6040_AR7dot4_EXPT.mat' and poolKiteWings.mat
% prescribedGndStn_bs% Dot indexing is not supported for variables of this type
% prescribedGndStn001_bs
% pathFollowingVhcl_bs% Unrecognized method, property, or field 'setIxx' setRwingLE_cm for class 'OCT.vehicle'

% fullScale1thrMod_bs% Unrecognized method, property, or field 'setTurbDiam' setWingNACA for class 'OCT.vehicle'.
% ayazAirborneSynFlow_bs% SquaredExponentialKernel
% ayazThreeTetVhcl_bs% Unrecognized method, property, or field 'setTurbDiam' setIxx for class 'OCT.vehicle'
% ayazAirborneVhcl_bs% Error using rmdir
% ayazFullScaleOneThrVhcl_bs% calcFluidDynamicCoefffs obj.hydroCharacterization.Value
% ayazOptVhcl_bs% vhcl.calcFluidDynamicCoefffs
% ayazThreeTetVhclForComp_bs% calcFluidDynamicCoefffs obj.hydroCharacterization.Value

if 0
gpkfAltitudeOptimization_bs% dep on ayazAirborneSynFlow_bs
gpkfPathOptAirborne_bs% dep on ayazAirborneSynFlow_bs
gpkfPathOptWithRGPAirborne_bs% dep on ayazAirborneSynFlow_bs
omniscientAltitudeOpt_bs% dep on ayazAirborneSynFlow_bs

lineAngleSensor_bs% dependent on thrAngLAS.mat
lineAngleSensorObserver_bs% dependent on thrAngLAS.mat
lineAngleSensorBoat_bs% dependent on thrAngLAS.mat
end

% sensitivityAnalysis_bs% calcFluidDynamicCoefffs obj.hydroCharacterization.Value
% pathFollowingVhclForComp_bs% calcFluidDynamicCoefffs obj.hydroCharacterization.Value
% constXYZ_varT_SineWave_bs% getBusDims
