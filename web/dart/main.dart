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
import 'dart:async';
import 'ntango/ntango.dart';

part 'aset.dart';
part 'beetle.dart';
part 'fly.dart';
part 'frog.dart';
part 'lilypad.dart';
part 'pond.dart';
part 'turtle.dart';
part 'program.dart';
part 'workspace.dart';
part 'fblocks/scoreboard.dart';


bool SHOW_FASTFORWARD = false;
bool SHOW_TURN_BLOCK = false;
bool SHOW_DIE_BLOCK = false;
bool SHOW_WAIT_BLOCK = false;
bool SHOW_PREVIEW = false;
bool SHOW_WAIT_TIMEOUT = false;
bool SHOW_STATUS = false;
bool AUTO_REPEAT = false;
bool FROG_SIZE_VARIATION = false;
bool DRAG_LILYPADS = false;
bool FROGS_PUSH = false;
bool FROGS_BLOCK = true;

// Maximum number of frogs of a given color
int MAX_FLIES = 0;
int MAX_FROGS = 10;
int MAX_BEETLES = 6;
int MAX_GEMS = 0;

void main() {

  Logging.init();
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
  
  // create frog pond
  FrogPond pond = new FrogPond();
}
