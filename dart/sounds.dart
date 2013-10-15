/*
 * Computer History Museum Exhibit
 */
part of ComputerHistory;

class Sounds {

  static AudioContext audio = new AudioContext();
  static Map sounds = new Map();
  static bool mute = false;


  static void loadSound(String name) {
    AudioElement audio = new AudioElement();
    audio.src = "sounds/$name.wav";
    sounds[name] = audio;
    /*
    HttpRequest http = new HttpRequest();
    http.responseType = "arraybuffer";
    http.onLoad.listen((e) {
      audio.decodeAudioData(
          http.response,
          (buffer) { sounds[name] = buffer; },
          (err) => print(err));
    });
    http.open('GET', "sounds/$name.wav");
    http.send();
    */
  }


  static void playSound(String name) {
    if (sounds[name] != null && !mute) {
      sounds[name].volume = 0.6;
      sounds[name].play();
    }
    /*
    if (sounds[name] == null) return;
    AudioBufferSourceNode source = audio.createBufferSource();
    source.connect(audio.destination, 0, 0);
    source.buffer = sounds[name];
    source.loop = false;
    source.gain.value = 0.2;
    source.playbackRate.value = 1;
    source.start(0);
    */
  }

}