/*
 * Computer History Museum
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


class Logging {
  
  
/**
 * Initializes the messaging protocol for log data
 */
  static void init() {
    /*
    window.onMessage.listen((event) {
      String s = "${event.data}";
      if (s.startsWith("upload-error: ")) {
        Logging.onUploadError(s.substring(14));
      } else if (s.startsWith("upload-success: ")) {
        Logging.onUploadSuccess(s.substring(16));
      }
    });
    */
  }
  
  
/**
 * Generate a "unique" id number for this app instance using a random int
 * TODO: This would be better with a mac address or a GUID
 */
  static String getLogID() {
    if (!window.localStorage.containsKey("log-id")) {
      Random r = new Random();
      String id = "${r.nextInt(1000000)}";
      window.localStorage["log-id"] = id;
    }
    // stash the id number in local storage
    return window.localStorage["log-id"];
  }


/**
 * Send a line to the log
 */
  static void logEvent(String event, [var data = null]) {
    DateTime date = new DateTime.now();
    var packet = {
      "timestamp" : date.millisecondsSinceEpoch,
      "event" : event,
      "data" : (data == null) ? "" : data
    };
    window.localStorage["log-item-$date"] = JSON.encode(packet);
  }
  

  /*
   * Send a window message to javascript
   */
  static void sendMessage(String msg) {
    String origin = "${window.location.protocol}//${window.location.host}"; 
    window.postMessage(msg, origin);
  }


  static void onUploadError(String message) {
    print("Error uploading logs: $message");
  }
  
  
  static void onUploadSuccess(String message) {
    print("Upload success: $message");
  }
}