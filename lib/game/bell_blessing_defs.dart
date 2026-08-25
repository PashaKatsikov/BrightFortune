import 'battle_state.dart';
import 'bright_fortune_game.dart';

/// The three one-tap blessings the Golden Bell can offer while its warning
/// banner is on screen ahead of a dangerous wave. Exactly one is offered per
/// warning, chosen to counter whatever that wave is about to throw at the
/// player (see [BrightFortuneGame.prepareBellBlessing]).
enum BellBlessingKind { shield, energy, focus }

extension BellBlessingKindX on BellBlessingKind {
  String get label {
    switch (this) {
      case BellBlessingKind.shield:
        return 'Shield Chime!';
      case BellBlessingKind.energy:
        return 'Energy Chime!';
      case BellBlessingKind.focus:
        return 'Focus Chime!';
    }
  }

  String get hint {
    switch (this) {
      case BellBlessingKind.shield:
        return 'Tap: shield the walls!';
      case BellBlessingKind.energy:
        return 'Tap: surge of energy!';
      case BellBlessingKind.focus:
        return 'Tap: empower the towers!';
    }
  }

  void apply(BrightFortuneGame game) {
    switch (this) {
      case BellBlessingKind.shield:
        game.state.addBuff(BuffType.wallShield, 0.5, 4);
        break;
      case BellBlessingKind.energy:
        game.state.energy = (game.state.energy + game.state.energyMax * 0.22).clamp(0.0, game.state.energyMax);
        break;
      case BellBlessingKind.focus:
        game.state.addBuff(BuffType.towerDamage, 0.4, 5);
        break;
    }
  }
}
