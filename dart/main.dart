/*
 * Computer History Museum Frog Pond
 * Copyright (c) 2013 Michael S. Horn
 * 
 *           Michael S. Horn (michael-horn@northwestern.edu)
 *           Northwestern University
 *           2120 Campus Drive
 *           Evanston, IL 60613
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License (version 2) as
 * published by the Free Software Foundation.
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
library ComputerHistory;

import 'dart:collection';
import 'dart:html';
import 'dart:math';
import 'dart:json' as json;
import 'dart:async';
import 'dart:web_audio';

part 'fly.dart';
part 'frog.dart';
part 'gem.dart';
part 'lilypad.dart';
part 'matrix.dart';
part 'pond.dart';
part 'sounds.dart';
part 'touch.dart';
part 'turtle.dart';
part 'tween.dart';
part 'utils.dart';
part 'program.dart';
part 'fblocks/block.dart';
part 'fblocks/bug.dart';
part 'fblocks/control.dart';
part 'fblocks/if.dart';
part 'fblocks/menu.dart';
part 'fblocks/parameter.dart';
part 'fblocks/repeat.dart';
part 'fblocks/start.dart';
part 'fblocks/status.dart';
part 'fblocks/wait.dart';
part 'fblocks/workspace.dart';


const CONFIG_JSON = '''
{
  "auto-repeat" : true,
  "fast-forward" : false
}
''';

var CONFIG;


bool getConfigFlag(String name) {
  if (CONFIG != null && CONFIG[name] is bool) {
    return CONFIG[name];
  } else {
    return false;
  }
}


void main() {

  Sounds.loadSound("hop");
  Sounds.loadSound("skip");
  Sounds.loadSound("jump");
  Sounds.loadSound("chimes");
  Sounds.loadSound("croak");
  Sounds.loadSound("crunch");
  Sounds.loadSound("sing");
  Sounds.loadSound("chirp");
  Sounds.loadSound("click");
  Sounds.loadSound("splash");
  Sounds.loadSound("tick");
  Sounds.loadSound("turn");
  Sounds.loadSound("swoosh");
  Sounds.loadSound("gulp");
  
  // parse configuration settings
  CONFIG = json.parse(CONFIG_JSON);
  
  // create frog pond
  FrogPond pond = new FrogPond();
}
