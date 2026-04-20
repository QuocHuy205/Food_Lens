import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:food_lens/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/locale_provider.dart';
import '../../../../core/theme/theme_mode_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              context.pop();
              return;
            }
            context.go('/profile');
          },
        ),
        title: Text(l10n.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionTitle(l10n.general),
          const SizedBox(height: 10),
          _SettingCard(
            child: Column(
              children: [
                _ThemeSelectorTile(
                  currentMode: themeMode,
                  onTap: () => _showThemeModePicker(context, ref, themeMode),
                ),
                const Divider(height: 1),
                _LanguageSelectorTile(
                  locale: locale,
                  onTap: () => _showLanguagePicker(context, ref, locale),
                ),
                const Divider(height: 1),
                _StaticSettingTile(
                  icon: Icons.notifications_outlined,
                  title: l10n.notifications,
                  subtitle: l10n.notificationsSubtitle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showThemeModePicker(
    BuildContext context,
    WidgetRef ref,
    ThemeMode currentMode,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final notifier = ref.read(themeModeProvider.notifier);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        final onSurface = Theme.of(sheetContext).colorScheme.onSurface;
        final secondaryText = onSurface.withValues(alpha: 0.75);

        Widget optionTile({
          required ThemeMode mode,
          required IconData icon,
          required String title,
          required String subtitle,
        }) {
          final selected = currentMode == mode;

          return ListTile(
            onTap: () {
              notifier.setThemeMode(mode);
              Navigator.of(sheetContext).pop();
            },
            leading: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            title: Text(
              title,
              style: TextStyle(
                color: onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              subtitle,
              style: TextStyle(
                color: secondaryText,
                fontSize: 12,
              ),
            ),
            trailing: selected
                ? const Icon(Icons.check_circle, color: AppColors.primary)
                : Icon(Icons.circle_outlined, color: secondaryText),
          );
        }

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: secondaryText.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.chooseTheme,
                  style: TextStyle(
                    color: onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                optionTile(
                  mode: ThemeMode.system,
                  icon: Icons.phone_android,
                  title: l10n.themeSystem,
                  subtitle: l10n.themeSystemSubtitle,
                ),
                optionTile(
                  mode: ThemeMode.light,
                  icon: Icons.light_mode,
                  title: l10n.themeLight,
                  subtitle: l10n.themeLightSubtitle,
                ),
                optionTile(
                  mode: ThemeMode.dark,
                  icon: Icons.dark_mode,
                  title: l10n.themeDark,
                  subtitle: l10n.themeDarkSubtitle,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLanguagePicker(
    BuildContext context,
    WidgetRef ref,
    Locale? currentLocale,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final notifier = ref.read(localeProvider.notifier);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        final onSurface = Theme.of(sheetContext).colorScheme.onSurface;
        final secondaryText = onSurface.withValues(alpha: 0.75);

        Widget optionTile({
          required Locale? locale,
          required IconData icon,
          required String title,
          required String subtitle,
          required VoidCallback onTap,
        }) {
          final selected = currentLocale == locale;

          return ListTile(
            onTap: () {
              onTap();
              Navigator.of(sheetContext).pop();
            },
            leading: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            title: Text(
              title,
              style: TextStyle(
                color: onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              subtitle,
              style: TextStyle(
                color: secondaryText,
                fontSize: 12,
              ),
            ),
            trailing: selected
                ? const Icon(Icons.check_circle, color: AppColors.primary)
                : Icon(Icons.circle_outlined, color: secondaryText),
          );
        }

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: secondaryText.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.chooseLanguage,
                  style: TextStyle(
                    color: onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                optionTile(
                  locale: null,
                  icon: Icons.phone_android,
                  title: l10n.languageSystem,
                  subtitle: l10n.languageSystemSubtitle,
                  onTap: notifier.setSystem,
                ),
                optionTile(
                  locale: const Locale('en'),
                  icon: Icons.language,
                  title: l10n.languageEnglish,
                  subtitle: l10n.languageEnglishSubtitle,
                  onTap: notifier.setEnglish,
                ),
                optionTile(
                  locale: const Locale('vi'),
                  icon: Icons.translate,
                  title: l10n.languageVietnamese,
                  subtitle: l10n.languageVietnameseSubtitle,
                  onTap: notifier.setVietnamese,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Text(
      text,
      style: TextStyle(
        color: onSurface,
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _SettingCard extends StatelessWidget {
  final Widget child;

  const _SettingCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final borderColor =
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.18);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: child,
    );
  }
}

class _ThemeSelectorTile extends StatelessWidget {
  final ThemeMode currentMode;
  final VoidCallback onTap;

  const _ThemeSelectorTile({
    required this.currentMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final secondaryText = onSurface.withValues(alpha: 0.78);
    final (title, subtitle, icon) = switch (currentMode) {
      ThemeMode.system => (
          l10n.themeSystem,
          l10n.themeSystemSubtitle,
          Icons.phone_android,
        ),
      ThemeMode.light => (
          l10n.themeLight,
          l10n.themeLightSubtitle,
          Icons.light_mode,
        ),
      ThemeMode.dark => (
          l10n.themeDark,
          l10n.themeDarkSubtitle,
          Icons.dark_mode,
        ),
    };

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: onSurface,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: secondaryText,
          fontSize: 11,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        color: secondaryText,
        size: 16,
      ),
    );
  }
}

class _LanguageSelectorTile extends StatelessWidget {
  final Locale? locale;
  final VoidCallback onTap;

  const _LanguageSelectorTile({
    required this.locale,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final secondaryText = onSurface.withValues(alpha: 0.78);

    final (title, subtitle, icon) = switch (locale?.languageCode) {
      'en' => (
          l10n.languageEnglish,
          l10n.languageEnglishSubtitle,
          Icons.language,
        ),
      'vi' => (
          l10n.languageVietnamese,
          l10n.languageVietnameseSubtitle,
          Icons.translate,
        ),
      _ => (
          l10n.languageSystem,
          l10n.languageSystemSubtitle,
          Icons.phone_android,
        ),
    };

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: onSurface,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: secondaryText,
          fontSize: 11,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        color: secondaryText,
        size: 16,
      ),
    );
  }
}

class _StaticSettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _StaticSettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final secondaryText = onSurface.withValues(alpha: 0.78);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      leading: Icon(icon, color: secondaryText, size: 20),
      title: Text(
        title,
        style: TextStyle(
          color: onSurface,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: secondaryText,
          fontSize: 11,
        ),
      ),
    );
  }
}
