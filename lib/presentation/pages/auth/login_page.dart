import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../../../core/controllers/auth_controller.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/theme/app_theme.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthController _authController = Get.find<AuthController>();

  bool _obscurePassword = true;
  bool _validationActivated = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    // Start animation after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() {
      _validationActivated = true;
    });

    if (_formKey.currentState!.validate()) {
      final success = await _authController.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (success) {
        Get.toNamed('/analytics');
      } else {
        // Show error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_authController.errorMessage.value),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    }
  }

  void _onFieldChanged() {
    if (_validationActivated) {
      setState(() {
        // This triggers a rebuild to clear errors as user types
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 768;

    return Scaffold(
      body: Stack(
        children: [
          // Main Content
          Container(
            decoration: BoxDecoration(
              gradient: themeProvider.isDarkMode
                  ? AppTheme.darkBackgroundGradient
                  : AppTheme.backgroundGradient,
            ),
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(isMobile ? 20 : 40),
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 450),
                            child: _buildLoginCard(themeProvider, isMobile),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // Theme Switcher Button
          Positioned(
            top: 16,
            right: 16,
            child: SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: _animationController,
                    curve: Curves.easeOutCubic,
                  )),
                  child: IconButton(
                    icon: Icon(
                      themeProvider.isDarkMode
                          ? Icons.light_mode_rounded
                          : Icons.dark_mode_rounded,
                      color:
                      themeProvider.isDarkMode ? Colors.white : Colors.black87,
                      semanticLabel: 'Toggle theme',
                    ),
                    onPressed: () {
                      Provider.of<ThemeProvider>(context, listen: false)
                          .toggleTheme();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginCard(ThemeProvider themeProvider, bool isMobile) {
    // Static container with backdrop filter
    return Container(
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode
            ? Colors.black.withOpacity(0.3)
            : Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: themeProvider.isDarkMode
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 30 : 40),
            // Animate only the content, not the backdrop
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo with animation
                      ScaleTransition(
                        scale: Tween<double>(
                          begin: 0.5,
                          end: 1.0,
                        ).animate(CurvedAnimation(
                          parent: _animationController,
                          curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
                        )),
                        child: _buildLogo(),
                      ),

                      const SizedBox(height: 40),

                      // Title with staggered animation
                      AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.5),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: _animationController,
                              curve: const Interval(0.3, 0.6, curve: Curves.easeOut),
                            )),
                            child: FadeTransition(
                              opacity: Tween<double>(
                                begin: 0.0,
                                end: 1.0,
                              ).animate(CurvedAnimation(
                                parent: _animationController,
                                curve: const Interval(0.3, 0.6, curve: Curves.easeOut),
                              )),
                              child: child,
                            ),
                          );
                        },
                        child: Text(
                          'Welcome Back',
                          style: TextStyle(
                            fontSize: isMobile ? 24 : 28,
                            fontWeight: FontWeight.w700,
                            color: themeProvider.isDarkMode
                                ? Colors.white
                                : Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 8),

                      AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.5),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: _animationController,
                              curve: const Interval(0.4, 0.7, curve: Curves.easeOut),
                            )),
                            child: FadeTransition(
                              opacity: Tween<double>(
                                begin: 0.0,
                                end: 1.0,
                              ).animate(CurvedAnimation(
                                parent: _animationController,
                                curve: const Interval(0.4, 0.7, curve: Curves.easeOut),
                              )),
                              child: child,
                            ),
                          );
                        },
                        child: Text(
                          'Sign in to continue to your dashboard',
                          style: TextStyle(
                            fontSize: 14,
                            color: themeProvider.isDarkMode
                                ? Colors.white70
                                : Colors.black54,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Email Field with staggered animation
                      _buildAnimatedTextField(
                        controller: _emailController,
                        label: 'Email',
                        hint: 'Enter your email',
                        icon: Icons.email_rounded,
                        keyboardType: TextInputType.emailAddress,
                        themeProvider: themeProvider,
                        animationInterval: const Interval(0.5, 0.8),
                        validator: (value) {
                          if (!_validationActivated) return null;
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!GetUtils.isEmail(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Password Field with staggered animation
                      _buildAnimatedTextField(
                        controller: _passwordController,
                        label: 'Password',
                        hint: 'Enter your password',
                        icon: Icons.lock_rounded,
                        obscureText: _obscurePassword,
                        themeProvider: themeProvider,
                        animationInterval: const Interval(0.6, 0.9),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                            color: themeProvider.isDarkMode
                                ? Colors.white54
                                : Colors.black54,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        validator: (value) {
                          if (!_validationActivated) return null;
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 12),

                      // Forgot Password with animation
                      AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(1, 0),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: _animationController,
                              curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
                            )),
                            child: FadeTransition(
                              opacity: Tween<double>(
                                begin: 0.0,
                                end: 1.0,
                              ).animate(CurvedAnimation(
                                parent: _animationController,
                                curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
                              )),
                              child: child,
                            ),
                          );
                        },
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => Get.toNamed('/forgot-password'),
                            child: Text(
                              'Forgot Password?',
                              style: TextStyle(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Login Button with animation
                      AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return ScaleTransition(
                            scale: Tween<double>(
                              begin: 0.8,
                              end: 1.0,
                            ).animate(CurvedAnimation(
                              parent: _animationController,
                              curve: const Interval(0.8, 1.0, curve: Curves.elasticOut),
                            )),
                            child: FadeTransition(
                              opacity: Tween<double>(
                                begin: 0.0,
                                end: 1.0,
                              ).animate(CurvedAnimation(
                                parent: _animationController,
                                curve: const Interval(0.8, 1.0, curve: Curves.easeOut),
                              )),
                              child: child,
                            ),
                          );
                        },
                        child: Obx(() => _buildLoginButton(themeProvider)),
                      ),

                      const SizedBox(height: 24),

                      // Register Link with animation
                      AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return FadeTransition(
                            opacity: Tween<double>(
                              begin: 0.0,
                              end: 1.0,
                            ).animate(CurvedAnimation(
                              parent: _animationController,
                              curve: const Interval(0.9, 1.0, curve: Curves.easeOut),
                            )),
                            child: child,
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: TextStyle(
                                color: themeProvider.isDarkMode
                                    ? Colors.white70
                                    : Colors.black54,
                              ),
                            ),
                            TextButton(
                              onPressed: () => Get.toNamed('/register'),
                              child: Text(
                                'Sign Up',
                                style: TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Center(
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.dashboard_rounded,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }

  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required ThemeProvider themeProvider,
    required Interval animationInterval,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.3),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: _animationController,
            curve: animationInterval,
          )),
          child: FadeTransition(
            opacity: Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: _animationController,
              curve: animationInterval,
            )),
            child: child,
          ),
        );
      },
      child: _buildTextField(
        controller: controller,
        label: label,
        hint: hint,
        icon: icon,
        themeProvider: themeProvider,
        obscureText: obscureText,
        suffixIcon: suffixIcon,
        keyboardType: keyboardType,
        validator: validator,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required ThemeProvider themeProvider,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          onChanged: (value) => _onFieldChanged(),
          style: TextStyle(
            color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: themeProvider.isDarkMode
                  ? Colors.white38
                  : Colors.black38,
            ),
            prefixIcon: Icon(
              icon,
              color: themeProvider.isDarkMode
                  ? Colors.white54
                  : Colors.black54,
            ),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: themeProvider.isDarkMode
                ? Colors.white.withOpacity(0.05)
                : Colors.black.withOpacity(0.03),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: themeProvider.isDarkMode
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.1),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: themeProvider.isDarkMode
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.1),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.primaryColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.errorColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton(ThemeProvider themeProvider) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: _authController.isLoading.value ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _authController.isLoading.value
            ? const SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        )
            : const Text(
          'Sign In',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}