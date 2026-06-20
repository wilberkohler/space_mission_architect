class AudioSettings {
  AudioSettings({
    this.soundEnabled = true,
    this.musicEnabled = true,
    this.masterVolume = 0.8,
    this.sfxVolume = 0.9,
    this.musicVolume = 0.35,
    this.ambientVolume = 0.25,
    this.criticalAlertsEnabled = true,
  });

  bool soundEnabled;
  bool musicEnabled;
  double masterVolume;
  double sfxVolume;
  double musicVolume;
  double ambientVolume;
  bool criticalAlertsEnabled;

  void toggleSound() {
    soundEnabled = !soundEnabled;
  }

  void setMasterVolume(double value) {
    masterVolume = value.clamp(0.0, 1.0);
  }

  void setSfxVolume(double value) {
    sfxVolume = value.clamp(0.0, 1.0);
  }

  void setMusicVolume(double value) {
    musicVolume = value.clamp(0.0, 1.0);
  }

  void setAmbientVolume(double value) {
    ambientVolume = value.clamp(0.0, 1.0);
  }
}
