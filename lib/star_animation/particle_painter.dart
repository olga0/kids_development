import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:kids_development/star_animation/particle_model.dart';

class ParticlePainter extends CustomPainter {
  List<ParticleModel> particles;
  Duration time;
  ui.Image starImage;
 // Random random = new Random();
  List<ParticleModel> particlesToDispose = [];
  ValueNotifier<bool> animationFinished;

  ParticlePainter(this.particles, this.time, this.starImage, this.animationFinished);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    paint.color = Colors.green.withAlpha(200);

    if (!animationFinished.value) {
      particles.forEach((particle) async {
        var progress = particle.animationProgress.progress(time);
        final animation = particle.tween.transform(progress);
        final ui.Offset position =
        Offset(animation["x"] * size.width, animation["y"] * size.height);
        //canvas.drawCircle(position, size.width * 0.2 * particle.size, paint);
        if (starImage != null) {
          if (position.dy <= -200) {
            particlesToDispose.add(particle);
          }
          else {
            canvas.drawImage(starImage, position, paint);
          }
        }
        else
          print('Could not load star image');
      });

      particlesToDispose.forEach((particle) {
        particles.remove(particle);
      });
      particlesToDispose.clear();
      if (particles.length == 0 && !animationFinished.value) {
        print('Animation finished');
        animationFinished.value = true;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}