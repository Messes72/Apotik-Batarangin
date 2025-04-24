// import 'package:flutter/material.dart';
// import 'dart:async';

// class ObatLoadingAnimation extends StatefulWidget {
//   final Color capsuleColor;
//   final Color capsuleShadeColor;
//   final Color capColor;
//   final Color capShadeColor;
//   final Color particleColor;
//   final double size;

//   const ObatLoadingAnimation({
//     Key? key,
//     this.capsuleColor = const Color(0xFFFF0000),
//     this.capsuleShadeColor = const Color(0xFFCC0000),
//     this.capColor = Colors.white,
//     this.capShadeColor = const Color(0xFFEEEEEE),
//     this.particleColor = Colors.white,
//     this.size = 1.0,
//   }) : super(key: key);

//   @override
//   State<ObatLoadingAnimation> createState() => _ObatLoadingAnimationState();
// }

// class _ObatLoadingAnimationState extends State<ObatLoadingAnimation> with TickerProviderStateMixin {
//   late AnimationController _capsuleController;
//   late AnimationController _capController;
//   late AnimationController _centerController;
//   late AnimationController _spinController;
//   late AnimationController _particleController1;
//   late AnimationController _particleController2;
//   late AnimationController _particleController3;

//   late Animation<double> _capPositionAnimation;
//   late Animation<double> _capRotationAnimation;
//   late Animation<double> _centerAnimation;
//   late Animation<double> _particleOpacity1;
//   late Animation<double> _particleOpacity2;
//   late Animation<double> _particleOpacity3;
//   late Animation<Offset> _particlePosition1;
//   late Animation<Offset> _particlePosition2;
//   late Animation<Offset> _particlePosition3;

//   bool _showCapsule = false;
//   bool _showCap = false;
//   bool _showParticles = false;

//   @override
//   void initState() {
//     super.initState();
    
//     // Capsule animation
//     _capsuleController = AnimationController(
//       duration: const Duration(milliseconds: 70),
//       vsync: this,
//     );
    
//     // Cap animation
//     _capController = AnimationController(
//       duration: const Duration(milliseconds: 770),
//       vsync: this,
//     );
    
//     _capPositionAnimation = Tween(begin: 1.0, end: 0.5).animate(
//       CurvedAnimation(parent: _capController, curve: Curves.easeInOut)
//     );
    
//     _capRotationAnimation = Tween(begin: 0.61, end: 0.0).animate(
//       CurvedAnimation(parent: _capController, curve: Curves.easeInOut)
//     );
    
//     // Center animation
//     _centerController = AnimationController(
//       duration: const Duration(milliseconds: 300),
//       vsync: this,
//     );
    
//     _centerAnimation = Tween(begin: 0.0, end: -0.17).animate(
//       CurvedAnimation(parent: _centerController, curve: Curves.easeInOut)
//     );
    
//     // Spin animation
//     _spinController = AnimationController(
//       duration: const Duration(milliseconds: 1400),
//       vsync: this,
//     );
    
//     // Particle animations
//     _particleController1 = AnimationController(
//       duration: const Duration(milliseconds: 1400),
//       vsync: this,
//     );
    
//     _particleController2 = AnimationController(
//       duration: const Duration(milliseconds: 1400),
//       vsync: this,
//     );
    
//     _particleController3 = AnimationController(
//       duration: const Duration(milliseconds: 1400),
//       vsync: this,
//     );
    
//     _particleOpacity1 = TweenSequence([
//       TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 50),
//       TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 1),
//       TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.0), weight: 49),
//     ]).animate(_particleController1);
    
//     _particleOpacity2 = TweenSequence([
//       TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 50),
//       TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 1),
//       TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.0), weight: 49),
//     ]).animate(_particleController2);
    
//     _particleOpacity3 = TweenSequence([
//       TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 50),
//       TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 1),
//       TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.0), weight: 49),
//     ]).animate(_particleController3);
    
//     _particlePosition1 = TweenSequence([
//       TweenSequenceItem(
//         tween: Tween(begin: const Offset(-0.54, 0), end: const Offset(-0.75, 30)),
//         weight: 50
//       ),
//       TweenSequenceItem(
//         tween: Tween(begin: const Offset(-0.75, 30), end: const Offset(-0.2, 30)),
//         weight: 50
//       ),
//     ]).animate(_particleController1);
    
//     _particlePosition2 = TweenSequence([
//       TweenSequenceItem(
//         tween: Tween(begin: const Offset(-0.5, 0), end: const Offset(-0.76, 52)),
//         weight: 50
//       ),
//       TweenSequenceItem(
//         tween: Tween(begin: const Offset(-0.76, 52), end: const Offset(-0.2, 52)),
//         weight: 50
//       ),
//     ]).animate(_particleController2);
    
//     _particlePosition3 = TweenSequence([
//       TweenSequenceItem(
//         tween: Tween(begin: const Offset(-0.56, 0), end: const Offset(-0.75, 70)),
//         weight: 50
//       ),
//       TweenSequenceItem(
//         tween: Tween(begin: const Offset(-0.75, 70), end: const Offset(-0.2, 70)),
//         weight: 50
//       ),
//     ]).animate(_particleController3);

//     // Start animation sequence
//     _startAnimationSequence();
//   }

//   void _startAnimationSequence() {
//     // Show capsule
//     Future.delayed(const Duration(milliseconds: 70), () {
//       setState(() => _showCapsule = true);
//       setState(() => _showParticles = true);
      
//       // Start particle animations with delays
//       _particleController1.forward();
//       Future.delayed(const Duration(milliseconds: 420), () {
//         _particleController2.forward();
//       });
//       Future.delayed(const Duration(milliseconds: 840), () {
//         _particleController3.forward();
//       });
      
//       Future.delayed(const Duration(milliseconds: 1400), () {
//         // Show cap
//         setState(() => _showCap = true);
//         _capController.forward();
        
//         Future.delayed(const Duration(milliseconds: 770), () {
//           // Center the capsule
//           _centerController.forward();
          
//           Future.delayed(const Duration(milliseconds: 200), () {
//             // Start spinning
//             _spinController.repeat();
//           });
//         });
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _capsuleController.dispose();
//     _capController.dispose();
//     _centerController.dispose();
//     _spinController.dispose();
//     _particleController1.dispose();
//     _particleController2.dispose();
//     _particleController3.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: 192 * widget.size,
//       height: 224 * widget.size,
//       child: Stack(
//         children: [
//           // Particles
//           if (_showParticles) ...[
//             // Particle 1
//             AnimatedBuilder(
//               animation: _particleController1,
//               builder: (context, child) {
//                 return Positioned(
//                   top: (0.65 * 224 * widget.size) + _particlePosition1.value.dy * widget.size,
//                   left: (0.53 * 192 * widget.size) + _particlePosition1.value.dx * widget.size,
//                   child: Opacity(
//                     opacity: _particleOpacity1.value,
//                     child: _buildParticle(),
//                   ),
//                 );
//               },
//             ),
//             // Particle 2
//             AnimatedBuilder(
//               animation: _particleController2,
//               builder: (context, child) {
//                 return Positioned(
//                   top: (0.57 * 224 * widget.size) + _particlePosition2.value.dy * widget.size,
//                   left: (0.44 * 192 * widget.size) + _particlePosition2.value.dx * widget.size,
//                   child: Opacity(
//                     opacity: _particleOpacity2.value,
//                     child: _buildParticle(),
//                   ),
//                 );
//               },
//             ),
//             // Particle 3
//             AnimatedBuilder(
//               animation: _particleController3,
//               builder: (context, child) {
//                 return Positioned(
//                   top: (0.53 * 224 * widget.size) + _particlePosition3.value.dy * widget.size,
//                   left: (0.56 * 192 * widget.size) + _particlePosition3.value.dx * widget.size,
//                   child: Opacity(
//                     opacity: _particleOpacity3.value,
//                     child: _buildParticle(),
//                   ),
//                 );
//               },
//             ),
//           ],
          
//           // Capsule animation
//           if (_showCapsule)
//             AnimatedBuilder(
//               animation: Listenable.merge([_centerController, _spinController]),
//               builder: (context, child) {
//                 return Positioned(
//                   bottom: 0,
//                   left: 0,
//                   right: 0,
//                   child: Transform.translate(
//                     offset: Offset(0, 224 * widget.size * _centerAnimation.value),
//                     child: Transform.rotate(
//                       angle: _spinController.value * 2 * 3.14159,
//                       origin: Offset(96 * widget.size, 150 * widget.size),
//                       child: Center(
//                         child: _buildCapsule(),
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
          
//           // Cap animation
//           if (_showCap)
//             AnimatedBuilder(
//               animation: _capController,
//               builder: (context, child) {
//                 return Positioned(
//                   top: 0,
//                   left: 192 * widget.size * _capPositionAnimation.value,
//                   child: Transform.rotate(
//                     angle: _capRotationAnimation.value,
//                     origin: const Offset(0, 0),
//                     child: _buildCap(),
//                   ),
//                 );
//               },
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCapsule() {
//     return Container(
//       width: 58 * widget.size,
//       height: 77 * widget.size,
//       decoration: BoxDecoration(
//         color: widget.capsuleColor,
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(13 * widget.size),
//           topRight: Radius.circular(13 * widget.size),
//           bottomLeft: Radius.circular(38 * widget.size),
//           bottomRight: Radius.circular(38 * widget.size),
//         ),
//         border: Border.all(
//           color: Colors.black,
//           width: 3 * widget.size,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: widget.capsuleShadeColor,
//             offset: Offset(-13 * widget.size, 0),
//             spreadRadius: 0,
//             blurRadius: 0,
//             inset: true,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCap() {
//     return Container(
//       width: 58 * widget.size,
//       height: 77 * widget.size,
//       decoration: BoxDecoration(
//         color: widget.capColor,
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(38 * widget.size),
//           topRight: Radius.circular(38 * widget.size),
//           bottomLeft: Radius.circular(13 * widget.size),
//           bottomRight: Radius.circular(13 * widget.size),
//         ),
//         border: Border.all(
//           color: Colors.black,
//           width: 3 * widget.size,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: widget.capShadeColor,
//             offset: Offset(-13 * widget.size, 0),
//             spreadRadius: 0,
//             blurRadius: 0,
//             inset: true,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildParticle() {
//     return Container(
//       width: 6 * widget.size,
//       height: 6 * widget.size,
//       decoration: BoxDecoration(
//         color: widget.particleColor,
//         borderRadius: BorderRadius.circular(2 * widget.size),
//         border: Border.all(
//           color: Colors.black,
//           width: 2 * widget.size,
//         ),
//       ),
//     );
//   }
// }