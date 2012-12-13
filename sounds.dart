/*
 * Computer History Museum Exhibit
 */
part of ComputerHistory;

class Sounds {

  static AudioContext audio = new AudioContext();
  static Map sounds = new Map();


  static void loadSound(String name) {
    HttpRequest http = new HttpRequest();
    http.responseType = "arraybuffer";
    http.on.loadEnd.add((e) {
      audio.decodeAudioData(
          http.response, 
          (buffer) { sounds[name] = buffer; }, 
          (err) => print(err));
    });
    http.open('GET', "sounds/$name.wav");
    http.send();
  }


  static void playSound(String name) {
     if (sounds[name] == null) return;
     AudioBufferSourceNode source = audio.createBufferSource();
     source.connect(audio.destination, 0, 0);
     source.buffer = sounds[name];
     source.loop = false;
     source.gain.value = 0.2;
     source.playbackRate.value = 1;
     source.start(0);
  }

}