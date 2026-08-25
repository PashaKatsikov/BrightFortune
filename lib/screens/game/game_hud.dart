import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/assets.dart';
import '../../core/colors.dart';
import '../../core/text_styles.dart';
import '../../data/tower_catalog.dart';
import '../../game/bright_fortune_game.dart';
import '../../models/tower_def.dart';
import '../../widgets/panel_box.dart';

/// Polls the Flame game's mutable [BattleState] on a fixed interval and
/// rebuilds a small, cheap widget tree - avoids coupling Flutter's build
/// system to Flame's 60fps update loop while still feeling responsive.
class GameHud extends StatefulWidget {
  final BrightFortuneGame game;
  final VoidCallback onPause;

  const GameHud({super.key, required this.game, required this.onPause});

  @override
  State<GameHud> createState() => _GameHudState();
}

class _GameHudState extends State<GameHud> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 80), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The Flame game initializes `state` asynchronously in onLoad(), which
    // can still be in flight on the very first HUD build since GameWidget
    // and GameHud are mounted together. Render nothing until it's ready.
    if (!widget.game.isLoaded) return const SizedBox.shrink();
    final state = widget.game.state;
    return Stack(
      children: [
        // Top bar
        Positioned(
          top: 8,
          left: 8,
          right: 8,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TopStatPanel(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.favorite_rounded, color: AppColors.red, size: 20),
                    const SizedBox(width: 6),
                    SizedBox(
                      width: 90,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: state.corePercent,
                          minHeight: 12,
                          backgroundColor: Colors.black45,
                          valueColor: AlwaysStoppedAnimation(
                            state.corePercent > 0.4 ? AppColors.green : AppColors.red,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Image.asset(Assets.starShard, width: 18, height: 18),
                    const SizedBox(width: 4),
                    Text(state.energy.toStringAsFixed(0), style: AppText.stat(size: 14)),
                  ],
                ),
              ),
              const Spacer(),
              _TopStatPanel(
                child: Text(
                  state.intermission
                      ? (state.waveNumber >= state.totalWaves ? 'Get Ready!' : 'Wave ${state.waveNumber + 1} in ${state.intermissionRemaining.clamp(0.0, 99).toStringAsFixed(0)}s')
                      : 'Wave ${state.waveNumber} / ${state.totalWaves}',
                  style: AppText.stat(size: 15),
                ),
              ),
              const Spacer(),
              _TopStatPanel(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(Assets.goldenCoin, width: 20, height: 20),
                    const SizedBox(width: 4),
                    Text('${state.coinsEarned}', style: AppText.stat(size: 14)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _PauseButton(onTap: widget.onPause),
            ],
          ),
        ),

        // Bell warning banner
        if (widget.game.bellMessage != null)
          Positioned(
            top: 54,
            left: 0,
            right: 0,
            child: Center(
              child: _BellBanner(text: widget.game.bellMessage!),
            ),
          ),

        // Bottom bar: focus selection + burst
        Positioned(
          bottom: 6,
          left: 8,
          right: 8,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: PanelBox(
                  borderRadius: 20,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: TowerCatalog.all.map((def) {
                      final focused = state.focusedTower == def.kind;
                      return _FocusButton(
                        def: def,
                        focused: focused,
                        suppressed: focused && state.boostSuppressed,
                        onTap: () => setState(() => widget.game.setFocus(def.kind)),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _BurstButton(
                percent: state.burstPercent,
                ready: state.burstCharge >= state.burstMax,
                onTap: () => setState(() => widget.game.triggerBrightBurst()),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TopStatPanel extends StatelessWidget {
  final Widget child;
  const _TopStatPanel({required this.child});

  @override
  Widget build(BuildContext context) {
    return PanelBox(
      borderRadius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: child,
    );
  }
}

class _PauseButton extends StatelessWidget {
  final VoidCallback onTap;
  const _PauseButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          gradient: AppColors.purpleButton,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white70, width: 2),
        ),
        child: const Icon(Icons.pause_rounded, color: Colors.white, size: 22),
      ),
    );
  }
}

class _BellBanner extends StatelessWidget {
  final String text;
  const _BellBanner({required this.text});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 350),
      curve: Curves.elasticOut,
      builder: (context, v, child) => Transform.scale(scale: v, child: child),
      child: PanelBox(
        borderRadius: 30,
        gradient: const LinearGradient(colors: [Color(0xFFFFE9A8), Color(0xFFE79A1C)]),
        borderColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(Assets.goldenWarningBell, width: 24, height: 24),
            const SizedBox(width: 8),
            Text(text, style: AppText.body_(size: 15, color: const Color(0xFF4A2A00), weight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}

class _FocusButton extends StatelessWidget {
  final TowerDef def;
  final bool focused;
  final bool suppressed;
  final VoidCallback onTap;

  const _FocusButton({required this.def, required this.focused, required this.suppressed, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 46,
        height: 46,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: focused ? (suppressed ? null : AppColors.goldButton) : null,
          color: focused ? (suppressed ? Colors.grey.shade700 : null) : Colors.black38,
          border: Border.all(
            color: focused ? Colors.white : Colors.white30,
            width: focused ? 2.5 : 1.5,
          ),
          boxShadow: focused && !suppressed
              ? [BoxShadow(color: AppColors.gold.withValues(alpha: 0.7), blurRadius: 10, spreadRadius: 1)]
              : null,
        ),
        child: Image.asset(def.sprite, fit: BoxFit.contain),
      ),
    );
  }
}

class _BurstButton extends StatelessWidget {
  final double percent;
  final bool ready;
  final VoidCallback onTap;

  const _BurstButton({required this.percent, required this.ready, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ready ? onTap : null,
      child: SizedBox(
        width: 58,
        height: 58,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 58,
              height: 58,
              child: CircularProgressIndicator(
                value: percent,
                strokeWidth: 5,
                backgroundColor: Colors.black45,
                valueColor: AlwaysStoppedAnimation(ready ? AppColors.gold : AppColors.blue),
              ),
            ),
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: ready ? AppColors.goldButton : null,
                color: ready ? null : Colors.black45,
                boxShadow: ready
                    ? [BoxShadow(color: AppColors.gold.withValues(alpha: 0.8), blurRadius: 14, spreadRadius: 2)]
                    : null,
              ),
              padding: const EdgeInsets.all(8),
              child: Image.asset(Assets.brightBurstCrystal, fit: BoxFit.contain),
            ),
          ],
        ),
      ),
    );
  }
}
