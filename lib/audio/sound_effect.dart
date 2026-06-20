enum AudioCategory {
  ui,
  countdown,
  test,
  launch,
  missionPhase,
  critical,
  result,
  ambient,
  voice,
  music,
}

enum SoundEffect {
  uiClick,
  uiBack,
  uiConfirm,
  tabSwitch,

  testStart,
  testBeep,
  testSuccess,
  testWarning,
  testFailed,

  countdownBeep,
  countdownFinalBeep,
  launchConfirm,
  launchIgnition,
  launchLiftoff,

  missionPhaseSuccess,
  missionPhaseWarning,
  missionPhaseFailed,

  criticalAlert,
  abortMission,
  flightTermination,

  successComplete,
  successPartial,
  missionFailed,
  catastrophicFailure,

  missionUnlocked,
  rivalHeadline,

  // --- Complementary / historical audio ---
  launchCountdownVoice,
  houstonProblem,
  sputnikBeep,
  quindarStart,
  quindarEnd,
  missionControlComputers,
  goThrottleUp,
  goForDeploy,
  meco,
  niceToBeInOrbit,
  rogerRoll,
  launchLiftoffAlt,
  slsLaunchAudio,

  // Ambient (loopable)
  ambientControlRoom,
  ambientDeepSpace,
  ambientSpaceFlight,

  // Tension / atmosphere
  spaceDanger,
  spaceRumble,

  // Milestones / speech
  milestoneAchieved,
  jfkMoonSpeech,

  // Background soundtrack / ambience scenes
  mainTheme,
  menuAmbient,
  missionAmbient,
  deepSpaceAmbient,

  // Agency profile selections
  agencySelectNasa,
  agencySelectUssr,
  agencySelectEsa,
  agencySelectIsro,

  // Progression / warnings
  careerPromotion,
  xpGain,
  noGoAlert,
}
