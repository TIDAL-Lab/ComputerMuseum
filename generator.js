
Blockly.JavaScript.frogs_hop = function() {
  return '[ "hop" ]';
};

Blockly.JavaScript.frogs_chirp = function() {
  return '[ "chirp" ]';
};

Blockly.JavaScript.frogs_turn = function() {
  var dir = this.getTitleValue('DIR');
  if (dir == 'left') {
     return '[ "left", [ "random", 100 ] ]';
  } else if (dir == 'right') {
     return '[ "right", [ "random", 100 ] ]';
  } else {
    return '[ "turn-random" ]';
  }
};

Blockly.JavaScript.frogs_turn_sound = function() {
  return '[ "turn-sound" ]';
};

Blockly.JavaScript.frogs_rest = function() {
  return '[ "rest", [ "random", 50 ] ]';
};

Blockly.JavaScript.frogs_hatch = function() {
  return '[ "hatch" ]';
};

Blockly.JavaScript.frogs_die = function() {
  return '[ "die" ]';
};

Blockly.JavaScript.controls_repeat = function() {
  var count = this.getTitleValue('COUNT');
  var branch = Blockly.JavaScript.statementToCode(this, 'DO');
  if (count == 'forever') {
    return '[ "forever", [ ' + branch + ' ] ]';
  } else {
     return '[ "repeat", ' + count + ', [ ' + branch + '] ]';
  }
};

Blockly.JavaScript.controls_wait = function() {
  return '[ "wait-sound" ]';
};

Blockly.JavaScript.controls_if = function() {
  var condition = this.getTitleValue('CONDITION');
  var block = Blockly.JavaScript.statementToCode(this, 'THEN');
  return '[ "if", [ "' + condition + '" ], [ ' + block + ' ] ]';
};
