import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../core/text_styles.dart';
import '../../services/player_progress.dart';
import '../../widgets/game_button.dart';
import '../../widgets/panel_box.dart';
import 'webview_screen.dart';

const String kPrivacyPolicyUrl = 'https://brighttfortune.site/privacy-policy.html';
const String kSupportUrl = 'https://brighttfortune.site/support.html';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.skyBackground),
        child: SafeArea(
          child: ListenableBuilder(
            listenable: PlayerProgress.instance,
            builder: (context, _) {
              final progress = PlayerProgress.instance;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        GameIconButton(icon: Icons.arrow_back_rounded, onPressed: () => Navigator.of(context).pop()),
                        const SizedBox(width: 12),
                        Text('Settings', style: AppText.heading(size: 24)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: SizedBox(
                          width: 480,
                          child: PanelBox(
                            padding: const EdgeInsets.all(22),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _SliderRow(
                                  icon: Icons.music_note_rounded,
                                  label: 'Music',
                                  value: progress.musicOn ? progress.musicVolume : 0,
                                  onChanged: (v) {
                                    progress.setMusicVolume(v);
                                    progress.setMusicOn(v > 0);
                                  },
                                ),
                                const SizedBox(height: 14),
                                _SliderRow(
                                  icon: Icons.volume_up_rounded,
                                  label: 'Sound Effects',
                                  value: progress.sfxOn ? progress.sfxVolume : 0,
                                  onChanged: (v) {
                                    progress.setSfxVolume(v);
                                    progress.setSfxOn(v > 0);
                                  },
                                ),
                                const SizedBox(height: 14),
                                _ToggleRow(
                                  icon: Icons.vibration_rounded,
                                  label: 'Vibration',
                                  value: progress.vibrationOn,
                                  onChanged: progress.setVibrationOn,
                                ),
                                const SizedBox(height: 14),
                                _QualityRow(progress: progress),
                                const SizedBox(height: 14),
                                Row(
                                  children: const [
                                    Icon(Icons.language_rounded, color: AppColors.textMuted, size: 22),
                                    SizedBox(width: 10),
                                    Text('Language', style: TextStyle(color: AppColors.textMuted, fontFamily: 'Nunito', fontSize: 15)),
                                    Spacer(),
                                    Text('English', style: TextStyle(color: Colors.white, fontFamily: 'Nunito', fontSize: 15, fontWeight: FontWeight.w800)),
                                  ],
                                ),
                                const SizedBox(height: 22),
                                Row(
                                  children: [
                                    Expanded(
                                      child: GameButton(
                                        label: 'Privacy Policy',
                                        style: GameButtonStyle.purple,
                                        width: double.infinity,
                                        height: 48,
                                        fontSize: 15,
                                        onPressed: () => Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => const WebViewScreen(title: 'Privacy Policy', url: kPrivacyPolicyUrl),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: GameButton(
                                        label: 'Support',
                                        style: GameButtonStyle.purple,
                                        width: double.infinity,
                                        height: 48,
                                        fontSize: 15,
                                        onPressed: () => Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => const WebViewScreen(title: 'Support', url: kSupportUrl),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  const _SliderRow({required this.icon, required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.gold, size: 22),
        const SizedBox(width: 10),
        SizedBox(width: 120, child: Text(label, style: AppText.body_(size: 15))),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.gold,
              inactiveTrackColor: Colors.white24,
              thumbColor: AppColors.goldLight,
              overlayColor: AppColors.gold.withValues(alpha: 0.2),
            ),
            child: Slider(value: value, onChanged: onChanged),
          ),
        ),
      ],
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({required this.icon, required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.gold, size: 22),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: AppText.body_(size: 15))),
        Switch(value: value, onChanged: onChanged, activeThumbColor: AppColors.gold),
      ],
    );
  }
}

class _QualityRow extends StatelessWidget {
  final PlayerProgress progress;

  const _QualityRow({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.tune_rounded, color: AppColors.gold, size: 22),
        const SizedBox(width: 10),
        Expanded(child: Text('Graphics Quality', style: AppText.body_(size: 15))),
        _QualityChip(
          label: 'Medium',
          selected: progress.quality == GraphicsQuality.medium,
          onTap: () => progress.setQuality(GraphicsQuality.medium),
        ),
        const SizedBox(width: 8),
        _QualityChip(
          label: 'High',
          selected: progress.quality == GraphicsQuality.high,
          onTap: () => progress.setQuality(GraphicsQuality.high),
        ),
      ],
    );
  }
}

class _QualityChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _QualityChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: selected ? AppColors.goldButton : null,
          color: selected ? null : Colors.black26,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? AppColors.panelBorder : Colors.white24),
        ),
        child: Text(label, style: AppText.body_(size: 13, color: selected ? const Color(0xFF4A2A00) : Colors.white70, weight: FontWeight.w800)),
      ),
    );
  }
}
