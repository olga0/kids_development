import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:kids_development/boolean.dart';
import 'package:kids_development/my_localizations.dart';
import 'package:kids_development/star_animation/particles.dart';
import 'package:kids_development/string_keys.dart';

class OddOneOutPage extends StatefulWidget {
  final String _locale;
  final Function _showAd;

  OddOneOutPage(this._locale, this._showAd);

  @override
  State<StatefulWidget> createState() {
    return OddOneOutPageState();
  }
}

enum TtsState { playing, stopped }

class OddOneOutPageState extends State<OddOneOutPage>
    with SingleTickerProviderStateMixin {
  List<OptionsSet> _optionsSetList = [];
  int _questionNumber = 1;
  int _numberOfQuestions = 10;
  List<OptionPicture> _optionPictures = [];
  List<bool> _picturesClicked = [false, false, false, false];
  late Widget _pageContent;
  bool firstScreenLoaded = false;
  late double width;
  late double height;
  late Boolean isCorrectAnswerClicked;
  AudioPlayer _audioPlayer = AudioPlayer();
  late FlutterTts flutterTts;

  TtsState ttsState = TtsState.stopped;

  late ValueNotifier<bool> _animationFinished;

  late Particles particles;

  @override
  void initState() {
    super.initState();
    _fillOptionsSetList();
    isCorrectAnswerClicked = new Boolean();
    _animationFinished = ValueNotifier(false);
    initTts();
    _animationFinished.addListener(() {
      if (_animationFinished.value) {
        print('window should pop');
        //Navigator.pop(context);
      }
    });
    particles = Particles(30, _animationFinished);
  }

  @override
  Widget build(BuildContext context) {
    print('odd_one_out: animation finished is ${_animationFinished.value}');

    if (!firstScreenLoaded) {
      width = MediaQuery.of(context).size.width * 0.4;
      height = MediaQuery.of(context).size.height * 0.3;
      _pageContent = _buildPageContent();
      firstScreenLoaded = true;
      _speak();
    }

    Widget body;
    if (_questionNumber == _numberOfQuestions && isCorrectAnswerClicked.value) {
      _playSound('sounds/you_win.mp3');

      body = Stack(
        children: <Widget>[
          AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            child: _pageContent,
          ),
          Positioned.fill(child: particles)
        ],
      );
    } else {
      body = AnimatedSwitcher(
          duration: Duration(milliseconds: 300), child: _pageContent);
    }
    return WillPopScope(
      onWillPop: () async {
        widget._showAd();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(MyLocalizations.of(widget._locale, StringKeys.oddOneOut)),
        ),
        body: body,
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.play_arrow),
          backgroundColor: (_questionNumber == _numberOfQuestions ||
                  !isCorrectAnswerClicked.value)
              ? Colors.grey
              : Colors.amber,
          onPressed: () {
            if (_questionNumber < _numberOfQuestions &&
                isCorrectAnswerClicked.value) {
              setState(() {
                _questionNumber++;
                _picturesClicked
                    .replaceRange(0, 4, [false, false, false, false]);
                print(_picturesClicked);
                isCorrectAnswerClicked.value = false;
                _pageContent = _buildPageContent();
              });
            } else {
              print(
                  'odd_one_out: animation finished is ${_animationFinished.value}');
            }
          },
        ),
      ),
    );
  }

  initTts() {
    flutterTts = FlutterTts()..setSpeechRate(0.8);
    flutterTts.setLanguage(widget._locale);

    flutterTts.setStartHandler(() {
      setState(() {
        ttsState = TtsState.playing;
      });
    });

    flutterTts.setCompletionHandler(() {
      setState(() {
        print("Complete");
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setErrorHandler((msg) {
      setState(() {
        ttsState = TtsState.stopped;
      });
    });
  }

  Future _speak() async {
    var result = await flutterTts
        .speak(MyLocalizations.of(widget._locale, StringKeys.oddOneOutTask));
    if (result == 1) setState(() => ttsState = TtsState.playing);
  }

  @override
  void dispose() {
    super.dispose();
    flutterTts.stop();
  }

  Future _playSound(String soundName) async {
    await _audioPlayer.play(AssetSource(soundName));
  }

  Widget _buildPageContent() {
    OptionsSet optionsSet = _optionsSetList.elementAt(_questionNumber - 1);
    _optionPictures.clear();
    _optionPictures.add(new OptionPicture(
        optionsSet.options.elementAt(0),
        width,
        height,
        isCorrectAnswerClicked,
        0,
        _handleRightAnswerTap,
        _picturesClicked));
    _optionPictures.add(new OptionPicture(
        optionsSet.options.elementAt(1),
        width,
        height,
        isCorrectAnswerClicked,
        1,
        _handleRightAnswerTap,
        _picturesClicked));
    _optionPictures.add(new OptionPicture(
        optionsSet.options.elementAt(2),
        width,
        height,
        isCorrectAnswerClicked,
        2,
        _handleRightAnswerTap,
        _picturesClicked));
    _optionPictures.add(new OptionPicture(
        optionsSet.options.elementAt(3),
        width,
        height,
        isCorrectAnswerClicked,
        3,
        _handleRightAnswerTap,
        _picturesClicked));

    return Column(
      key: ValueKey(_questionNumber),
      children: <Widget>[
        Row(
          children: <Widget>[
            _optionPictures.elementAt(0),
            _optionPictures.elementAt(1),
          ],
        ),
        Row(
          children: <Widget>[
            _optionPictures.elementAt(2),
            _optionPictures.elementAt(3),
          ],
        ),
      ],
    );
  }

  void _fillOptionsSetList() {
    OptionsSet optionsSet1 = OptionsSet([
      Option('butterfly1', false),
      Option('butterfly2', false),
      Option('butterfly3', false),
      Option('ladybug', true)
    ]..shuffle());

    OptionsSet optionsSet2 = OptionsSet([
      Option('flower1_red', false),
      Option('flower2_red', false),
      Option('flower3_white', true),
      Option('flower4_red', false)
    ]..shuffle());

    OptionsSet optionSet3 = OptionsSet([
      Option('bird', false),
      Option('parrot', false),
      Option('cat', true),
      Option('penguin', false),
    ]..shuffle());

    OptionsSet optionsSet4 = OptionsSet([
      Option('panther', false),
      Option('lamb', true),
      Option('tiger', false),
      Option('wolf', false),
    ]..shuffle());

    OptionsSet optionsSet5 = OptionsSet([
      Option('cactus', false),
      Option('flower4_red', false),
      Option('oak', false),
      Option('sea-dog', true)
    ]..shuffle());

    OptionsSet optionsSet6 = OptionsSet([
      Option('tulp_purple', false),
      Option('tulp_red', false),
      Option('tulp_yellow', false),
      Option('flower5_white', true)
    ]..shuffle());

    OptionsSet optionsSet7 = OptionsSet([
      Option('dolphin', false),
      Option('frog', false),
      Option('fish', false),
      Option('panther', true)
    ]..shuffle());

    OptionsSet optionsSet8 = OptionsSet([
      Option('cherry', false),
      Option('orange', false),
      Option('watermelon', false),
      Option('cactus', true)
    ]..shuffle());

    OptionsSet optionsSet9 = OptionsSet([
      Option('butterfly2', false),
      Option('bird', false),
      Option('ladybug', false),
      Option('elephant', true)
    ]..shuffle());

    OptionsSet optionsSet10 = OptionsSet([
      Option('oak', false),
      Option('palm', false),
      Option('tree', false),
      Option('flower2_red', true)
    ]..shuffle());

    _optionsSetList = [
      optionsSet1,
      optionsSet2,
      optionSet3,
      optionsSet4,
      optionsSet5,
      optionsSet6,
      optionsSet7,
      optionsSet8,
      optionsSet9,
      optionsSet10
    ]..shuffle();
  }

  void _handleRightAnswerTap() {
    setState(() {
      isCorrectAnswerClicked.value = true;
    });
  }

  List shuffle(List items) {
    var random = new Random();

    for (var i = items.length - 1; i > 0; i--) {
      var n = random.nextInt(i + 1);

      var temp = items[i];
      items[i] = items[n];
      items[n] = temp;
    }

    return items;
  }
}

class OptionPicture extends StatefulWidget {
  final Option _option;
  final double _width;
  final double _height;
  final Boolean _isCorrectAnswerClicked;
  final int _index;
  final Function _handleRightAnswerTap;
  final List<bool> _picturesClicked;

  OptionPicture(
      this._option,
      this._width,
      this._height,
      this._isCorrectAnswerClicked,
      this._index,
      this._handleRightAnswerTap,
      this._picturesClicked);

  @override
  State<StatefulWidget> createState() {
    return new OptionPictureState();
  }
}

class OptionPictureState extends State<OptionPicture> {
  AudioPlayer _audioPlayer = AudioPlayer();

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (!widget._picturesClicked.elementAt(widget._index)) {
      child = Image.asset(
        widget._option.imageName,
        width: widget._width,
        height: widget._height,
        fit: BoxFit.contain,
      );
    } else {
      String markImage = (widget._option.isCorrectAnswer)
          ? 'images/checkmark.png'
          : 'images/x.png';
      child = Stack(
        alignment: AlignmentDirectional.center,
        children: <Widget>[
          Image.asset(
            widget._option.imageName,
            width: widget._width,
            height: widget._height,
            fit: BoxFit.contain,
          ),
          Image.asset(
            markImage,
            width: widget._width,
            height: widget._height,
            fit: BoxFit.contain,
          ),
        ],
      );
    }

    return GestureDetector(
        onTap: _handleTap,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: child,
        ));
  }

  void _handleTap() {
    if (!widget._isCorrectAnswerClicked.value) {
      setState(() {
        widget._picturesClicked[widget._index] = true;
        if (widget._option.isCorrectAnswer) {
          widget._handleRightAnswerTap();
          print('correct answer chosen');
          print(widget._picturesClicked);
        }

        String sound = (widget._option.isCorrectAnswer)
            ? 'sounds/correct.mp3'
            : 'sounds/incorrect.mp3';
        _playSound(sound);
      });
    }
  }

  Future _playSound(String soundName) async {
    await _audioPlayer.play(AssetSource(soundName));
  }
}

class Option {
  late String imageName;
  late bool isCorrectAnswer;

  Option(String imageName, bool isCorrectAnswer) {
    this.imageName = 'images/$imageName.png';
    this.isCorrectAnswer = isCorrectAnswer;
  }
}

class OptionsSet {
  List<Option> options;

  OptionsSet(this.options);
}
