import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:kids_development/star_animation/particle_model.dart';
import 'package:kids_development/star_animation/particle_painter.dart';
import 'package:simple_animations/simple_animations/rendering.dart';

class Particles extends StatefulWidget {
  final int numberOfParticles;
  final ValueNotifier<bool> animationFinished;

  Particles(this.numberOfParticles, this.animationFinished);

  @override
  _ParticlesState createState() => _ParticlesState();
}

class _ParticlesState extends State<Particles> {
  final Random random = Random();
  late ui.Image starImage;
  final List<ParticleModel> particles = [];

  @override
  void initState() {
    List.generate(widget.numberOfParticles, (index) {
      particles.add(ParticleModel(random));
    });
    _loadStarImage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Rendering(
      builder: (context, time) {
        return starImage == null
            ? Container()
            : CustomPaint(
                painter: ParticlePainter(particles, time, starImage, widget.animationFinished),
              );
      },
    );
  }

  Future<void> _loadStarImage() async {
    ByteData data = await rootBundle.load('images/star.png');
    Uint8List lst = new Uint8List.view(data.buffer);
    ui.Codec codec = await ui.instantiateImageCodec(lst);
    ui.FrameInfo frameInfo = await codec.getNextFrame();
    starImage = frameInfo.image;
  }
}
