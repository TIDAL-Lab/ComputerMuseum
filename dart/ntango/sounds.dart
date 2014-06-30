/*
 * Frog Pond Evolution
 * Copyright (c) 2014 Michael S. Horn
 * 
 *           Michael S. Horn (michael-horn@northwestern.edu)
 *           Northwestern University
 *           2120 Campus Drive
 *           Evanston, IL 60613
 *           http://tidal.northwestern.edu
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation.
 * 
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */
part of NetTango;


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
      sounds[name].volume = 0.2;
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