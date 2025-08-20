import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimation();
    _startSplash();
  }

  void _initAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.bounceOut,
    ));

    // Iniciar animación inmediatamente
    _animationController.forward();
  }

  void _startSplash() async {
    // Reducir tiempo de splash para transición más rápida
    await Future.delayed(const Duration(milliseconds: 2500));
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF7B1FA2), // Deep Purple
              Color(0xFF8E24AA), // Purple
              Color(0xFFE91E63), // Pink
            ],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo container mejorado
                      Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white,
                              Colors.pink.shade50,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 25,
                              offset: Offset(0, 15),
                              spreadRadius: 5,
                            ),
                            BoxShadow(
                              color: Colors.pink.withOpacity(0.3),
                              blurRadius: 40,
                              offset: Offset(0, 0),
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Círculo pulsante de fondo
                            AnimatedBuilder(
                              animation: _animationController,
                              builder: (context, child) {
                                return Container(
                                  width: 250 + (30 * _animationController.value),
                                  height: 250 + (30 * _animationController.value),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.pink.withOpacity(0.1 * _animationController.value),
                                  ),
                                );
                              },
                            ),
                            // Logo personalizado PetMatch
                            Container(
                              width: 220,
                              height: 220,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Image.asset(
                                    'assets/petmatch.jpg',
                                    fit: BoxFit.cover,
                                    width: 216,
                                    height: 216,
                                    errorBuilder: (context, error, stackTrace) {
                                      // Si hay error cargando la imagen, mostrar ícono por defecto
                                      return Icon(
                                        Icons.pets,
                                        size: 90,
                                        color: Color(0xFFE91E63),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                            // Multiple floating hearts
                            Positioned(
                              top: 20,
                              right: 20,
                              child: AnimatedBuilder(
                                animation: _animationController,
                                builder: (context, child) {
                                  return Transform.translate(
                                    offset: Offset(
                                      7 * _animationController.value,
                                      -7 * _animationController.value,
                                    ),
                                    child: Icon(
                                      Icons.favorite,
                                      size: 32,
                                      color: Colors.red.withOpacity(_animationController.value),
                                    ),
                                  );
                                },
                              ),
                            ),
                            // Second heart
                            Positioned(
                              bottom: 20,
                              left: 20,
                              child: AnimatedBuilder(
                                animation: _animationController,
                                builder: (context, child) {
                                  return Transform.translate(
                                    offset: Offset(
                                      -3 * _animationController.value,
                                      3 * _animationController.value,
                                    ),
                                    child: Icon(
                                      Icons.favorite,
                                      size: 20,
                                      color: Colors.pink.withOpacity(_animationController.value * 0.8),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: 45),
                      
                      // App title con efecto de brillo
                      AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [
                                Colors.white,
                                Colors.pink.shade200,
                                Colors.white,
                              ],
                              stops: [
                                0.0,
                                _animationController.value,
                                1.0,
                              ],
                            ).createShader(bounds),
                            child: Text(
                              'PetMatch',
                              style: TextStyle(
                                fontSize: 50,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: 'AntonSC',
                                letterSpacing: 4,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.3),
                                    offset: Offset(2, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      
                      SizedBox(height: 10),
                      
                      // Subtitle
                      Text(
                        'Encuentra el amor peludo',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      
                      SizedBox(height: 50),
                      
                      // Loading indicator mejorado
                      AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 45,
                                height: 45,
                                child: CircularProgressIndicator(
                                  strokeWidth: 4,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white.withOpacity(0.8),
                                  ),
                                ),
                              ),
                              Container(
                                width: 25,
                                height: 25,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                                child: Icon(
                                  Icons.pets,
                                  size: 16,
                                  color: Color(0xFFE91E63),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      
                      SizedBox(height: 25),
                      
                      AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return Text(
                            'Preparando la experiencia...',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.8 + (0.2 * _animationController.value)),
                              fontWeight: FontWeight.w300,
                              letterSpacing: 1,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
