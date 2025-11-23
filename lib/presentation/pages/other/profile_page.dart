import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/controllers/auth_controller.dart';
import '../../../core/theme/app_theme.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthController authController = Get.find<AuthController>();
  final _nameController = TextEditingController();
  final _programDaysController = TextEditingController();
  bool _isEditingName = false;
  bool _isEditingProgramDays = false;

  @override
  void dispose() {
    _nameController.dispose();
    _programDaysController.dispose();
    super.dispose();
  }

  Future<void> _updateName() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) {
      Get.snackbar('Error', 'Name cannot be empty',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final success = await authController.updateUserProfile(name: newName);
    if (success) {
      setState(() => _isEditingName = false);
      Get.snackbar('Success', 'Name updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white);
    } else {
      Get.snackbar('Error', authController.errorMessage.value,
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> _updateProgramDays() async {
    final days = int.tryParse(_programDaysController.text);
    if (days == null || days < 0) {
      Get.snackbar('Error', 'Please enter a valid number',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final success = await authController.updateUserProfile(programDays: days);
    if (success) {
      setState(() => _isEditingProgramDays = false);
      Get.snackbar('Success', 'Production capacity updated',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white);
    } else {
      Get.snackbar('Error', authController.errorMessage.value,
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : Colors.black87;
    final textSecondary = isDark ? Colors.white70 : Colors.black54;

    return Obx(() {
      final user = authController.firestoreUser.value;
      final isLoading = authController.isLoading.value;

      if (user == null) {
        return const Center(child: CircularProgressIndicator());
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 1200;
            final isTablet = constraints.maxWidth > 600 && constraints.maxWidth <= 1200;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                _buildHeader(user, textPrimary, textSecondary, isDark, isDesktop),
                const SizedBox(height: 32),

                // Content Area - Responsive Layout
                if (isDesktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildLeftColumn(user, textPrimary, textSecondary, isDark, isLoading),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 3,
                        child: _buildRightColumn(user, textPrimary, textSecondary, isDark),
                      ),
                    ],
                  )
                else
                  Column(
                    children: [
                      _buildLeftColumn(user, textPrimary, textSecondary, isDark, isLoading),
                      const SizedBox(height: 24),
                      _buildRightColumn(user, textPrimary, textSecondary, isDark),
                    ],
                  ),
              ],
            );
          },
        ),
      );
    });
  }

  Widget _buildHeader(user, Color textPrimary, Color textSecondary, bool isDark, bool isDesktop) {
    return _GlassCard(
      isDark: isDark,
      child: Row(
        children: [
          CircleAvatar(
            radius: isDesktop ? 48 : 36,
            backgroundColor: AppTheme.primaryColor,
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
              style: TextStyle(
                color: Colors.white,
                fontSize: isDesktop ? 32 : 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_isEditingName)
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _nameController,
                          style: AppTheme.customTextStyle(
                            color: textPrimary,
                            fontSize: isDesktop ? 24 : 20,
                            fontWeight: FontWeight.w700,
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: _updateName,
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => setState(() => _isEditingName = false),
                      ),
                    ],
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          user.name,
                          style: AppTheme.customTextStyle(
                            color: textPrimary,
                            fontSize: isDesktop ? 24 : 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_rounded, size: 18),
                        onPressed: () {
                          _nameController.text = user.name;
                          setState(() => _isEditingName = true);
                        },
                      ),
                    ],
                  ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: AppTheme.customTextStyle(
                    color: textSecondary,
                    fontSize: isDesktop ? 14 : 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeftColumn(user, Color textPrimary, Color textSecondary, bool isDark, bool isLoading) {
    return Column(
      children: [
        // Production Capacity Card
        _GlassCard(
          isDark: isDark,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Production Capacity',
                    style: AppTheme.customTextStyle(
                      color: textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (!_isEditingProgramDays)
                    IconButton(
                      icon: const Icon(Icons.edit_rounded, size: 18),
                      onPressed: () {
                        _programDaysController.text = user.programDays.toString();
                        setState(() => _isEditingProgramDays = true);
                      },
                    ),
                ],
              ),
              const SizedBox(height: 16),
              if (_isEditingProgramDays)
                Column(
                  children: [
                    TextField(
                      controller: _programDaysController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: AppTheme.customTextStyle(
                        color: textPrimary,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Pieces per day',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => setState(() => _isEditingProgramDays = false),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: isLoading ? null : _updateProgramDays,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                          ),
                          child: isLoading
                              ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                              : const Text('Save'),
                        ),
                      ],
                    ),
                  ],
                )
              else
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryColor.withOpacity(0.15),
                        AppTheme.primaryColor.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.factory_rounded,
                        size: 48,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${user.programDays}',
                        style: AppTheme.customTextStyle(
                          color: textPrimary,
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'pieces per day',
                        style: AppTheme.customTextStyle(
                          color: textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRightColumn(user, Color textPrimary, Color textSecondary, bool isDark) {
    return Column(
      children: [
        // Account Information
        _GlassCard(
          isDark: isDark,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Account Information',
                style: AppTheme.customTextStyle(
                  color: textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              _InfoRow(
                icon: Icons.person_rounded,
                label: 'Full Name',
                value: user.name,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
              ),
              _InfoRow(
                icon: Icons.email_rounded,
                label: 'Email',
                value: user.email,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
              ),
              _InfoRow(
                icon: Icons.verified_user_rounded,
                label: 'User ID',
                value: user.uid.substring(0, 12) + '...',
                textPrimary: textPrimary,
                textSecondary: textSecondary,
              ),
              if (user.createdAt != null)
                _InfoRow(
                  icon: Icons.calendar_today_rounded,
                  label: 'Member Since',
                  value: _formatDate(user.createdAt!.toDate()),
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Actions
        _GlassCard(
          isDark: isDark,
          child: Column(
            children: [
              _ActionTile(
                icon: Icons.lock_reset_rounded,
                title: 'Change Password',
                subtitle: 'Update your account password',
                isDark: isDark,
                onTap: () {
                  // Implement password change
                  Get.snackbar('Info', 'Password change coming soon',
                      snackPosition: SnackPosition.BOTTOM);
                },
              ),
              _ActionTile(
                icon: Icons.logout_rounded,
                title: 'Sign Out',
                subtitle: 'Sign out from your account',
                isDark: isDark,
                color: Colors.red,
                onTap: () => authController.signOut(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _GlassCard extends StatelessWidget {
  final bool isDark;
  final Widget child;
  const _GlassCard({required this.isDark, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark
            ? Colors.black.withOpacity(0.3)
            : Colors.white.withOpacity(0.8),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color textPrimary;
  final Color textSecondary;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: AppTheme.primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTheme.customTextStyle(
                    color: textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTheme.customTextStyle(
                    color: textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDark;
  final Color? color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDark,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final actionColor = color ?? AppTheme.primaryColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : Colors.black.withOpacity(0.04),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: actionColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: actionColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.customTextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTheme.customTextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
          ],
        ),
      ),
    );
  }
}