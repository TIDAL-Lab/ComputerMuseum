

//--------------------------------------------------------------------------
// HOP      
//--------------------------------------------------------------------------
Blockly.Language.frogs_hop = {
  category: 'Frogs',
  //helpUrl: 'http://www.example.com/',
  init: function() {
    this.setColour(290);
    this.appendDummyInput().appendTitle("hop")
    this.setPreviousStatement(true);
    this.setNextStatement(true);
    this.setTooltip('');
  }
};


//--------------------------------------------------------------------------
// CHIRP
//--------------------------------------------------------------------------
Blockly.Language.frogs_chirp = {
  category: 'Frogs',
  //helpUrl: 'http://www.example.com/',
  init: function() {
    this.setColour(290);
    this.appendDummyInput().appendTitle("chirp")
    this.setPreviousStatement(true);
    this.setNextStatement(true);
    this.setTooltip('');
  }
};


//--------------------------------------------------------------------------
// TURN 
//--------------------------------------------------------------------------
Blockly.Language.frogs_turn = {
  category: 'Frogs',
  init: function() {
    this.setColour(290);
    this.appendDummyInput()
        .appendTitle("turn")
        .appendTitle(new Blockly.FieldDropdown([["left", "left"], ["right", "right"], ["random", "random"]]), "DIR");
    this.setPreviousStatement(true);
    this.setNextStatement(true);
    this.setTooltip('Turn left');
  }
};


//--------------------------------------------------------------------------
// TURN TOWARDS SOUND
//--------------------------------------------------------------------------
Blockly.Language.frogs_turn_sound = {
  category: 'Frogs',
  init: function() {
    this.setColour(290);
    this.appendDummyInput().appendTitle("turn towards sound");
    this.setPreviousStatement(true);
    this.setNextStatement(true);
    this.setTooltip('Turn in the direction of a sound');
  }
};


//--------------------------------------------------------------------------
// REST
//--------------------------------------------------------------------------
Blockly.Language.frogs_rest = {
  category: 'Frogs',
  init: function() {
    this.setColour(290);
    this.appendDummyInput().appendTitle("rest")
    this.setPreviousStatement(true);
    this.setNextStatement(true);
    this.setTooltip('Rest for a moment');
  }
};


//--------------------------------------------------------------------------
// HATCH
//--------------------------------------------------------------------------
Blockly.Language.frogs_hatch = {
  category: 'Frogs',
  init: function() {
    this.setColour(290);
    this.appendDummyInput().appendTitle("hatch")
    this.setPreviousStatement(true);
    this.setNextStatement(true);
    this.setTooltip('Make a new frog!');
  }
};


//--------------------------------------------------------------------------
// DIE
//--------------------------------------------------------------------------
Blockly.Language.frogs_die = {
  category: 'Frogs',
  init: function() {
    this.setColour(290);
    this.appendDummyInput().appendTitle("die")
    this.setPreviousStatement(true);
    this.setNextStatement(true);
    this.setTooltip('End of life for this frog');
  }
};


//--------------------------------------------------------------------------
// REPEAT 
//--------------------------------------------------------------------------
Blockly.Language.controls_repeat = {
  category: 'Control',
  init: function() {
    this.setColour(120);
    this.appendDummyInput()
        .appendTitle("repeat")
        .appendTitle(new Blockly.FieldDropdown([["forever", "forever"], ["2", "2"], ["3", "3"], ["4", "4"], ["5", "5"], ["6", "6"]]), "COUNT");
    this.appendStatementInput('DO')
//        .appendTitle(Blockly.LANG_CONTROLS_REPEAT_INPUT_DO);
    this.setPreviousStatement(true);
    this.setNextStatement(true);
    this.setTooltip('Blocks inside this get run over and over again.');
  }
};


//--------------------------------------------------------------------------
// WAIT
//--------------------------------------------------------------------------
Blockly.Language.controls_wait = {
  category: 'Control',
  init: function() {
    this.setColour(120);
    this.appendDummyInput().appendTitle("wait for sound");
    this.setPreviousStatement(true);
    this.setNextStatement(true);
    this.setTooltip('Wait until you hear a sound');
  }
};


//--------------------------------------------------------------------------
// IF 
//--------------------------------------------------------------------------
Blockly.Language.controls_if = {
  category: 'Control',
  init: function() {
    this.setColour(120);
    this.appendDummyInput()
        .appendTitle("if")
        .appendTitle(new Blockly.FieldDropdown([["near-edge", "near-edge"], ["hear-sound", "hear-sound"]]), "CONDITION");
    this.appendStatementInput("THEN");
    this.setPreviousStatement(true);
    this.setNextStatement(true);
    this.setTooltip('');
  }
};
