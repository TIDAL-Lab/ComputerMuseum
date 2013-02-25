//Numbers and Sensors
// -> the relevant portions of math
// -> the relevant portions of logic
// -> frog-specific dsl sensor predicates
// -> the values they consume

// hears : (aural a) -> (a -> Bool)
//hears is a hearing predicate. As such, it should, in addition to returning a bool,
//update a 'heard_in_direction' variable of type 'direction'

SENSES = 'Numbers and Sensors';
VALS = 'Colors and Sounds';

Blockly.Language.numbers_and_sensors_hear = {
  category: SENSES,
  helpUrl: 'http://www.example.com/',
  init: function() {
    this.setColour(160);
    this.appendDummyInput()
      .appendTitle("Hears?");
    this.appendValueInput("NAME");
    this.setOutput(true);
    this.setTooltip('');
  }
};

// sees : (visual a) -> (a -> Bool) 
//sees is a vision predicate. As such, it should, in addition to returning a bool,
//also update a 'last_seen' variable or similar.
Blockly.Language.numbers_and_sensors_sees = {
  category: SENSES,
  helpUrl: 'http://www.example.com/',
  init: function() {
    this.setColour(160);
    this.appendDummyInput()
      .appendTitle("Sees?");
    this.appendValueInput("NAME");
    this.setOutput(true);
    this.setTooltip('');
  }
};

// visual datatypes
// we wil probably want to have the actual evalation be typed
// so that when kids do something silly, we can give them really,
// REALLY good error messages
// visual stimuli are either:
// -> frogs,
// -> frogs of a given color,
// -> or the last thing you saw
Blockly.Language.numbers_and_sensors_frog_sensed = {
  category: SENSES,
  helpUrl: 'http://www.example.com/',
  init: function() {
    this.setColour(160);
    this.appendDummyInput()
      .appendTitle("Frog");
    this.setOutput(true);
    this.setTooltip('');
  }
};


//color: takes a color-value (like blue,  or whatever)
//passes it into Sees?
Blockly.Language.numbers_and_sensors_color_sensed = {
  category: SENSES,
  helpUrl: 'http://www.example.com/',
  init: function() {
    this.setColour(160);
    this.appendDummyInput()
      .appendTitle("Color");
    this.appendValueInput("color_value");
    this.setOutput(true);
    this.setTooltip('');
  }
};

//some default colors for frog-breeds
Blockly.Language.numbers_and_sensors_color_red = {
  category: VALS,
  helpUrl: 'http://www.example.com/',
  init: function() {
    this.setColour(0);
    this.appendDummyInput()
      .appendTitle("Red");
    this.setOutput(true);
    this.setTooltip('');
  }
};

Blockly.Language.numbers_and_sensors_color_green = {
  category: VALS,
  helpUrl: 'http://www.example.com/',
  init: function() {
    this.setColour(120);
    this.appendDummyInput()
      .appendTitle("Green");
    this.setOutput(true);
    this.setTooltip('');
  }
};

Blockly.Language.numbers_and_sensors_color_blue = {
  category: VALS,
  helpUrl: 'http://www.example.com/',
  init: function() {
    this.setColour(210);
    this.appendDummyInput()
      .appendTitle("Blue");
    this.setOutput(true);
    this.setTooltip('');
  }
};

Blockly.Language.numbers_and_sensors_color_yellow = {
  category: VALS,
  helpUrl: 'http://www.example.com/',
  init: function() {
    this.setColour(55);
    this.appendDummyInput()
      .appendTitle("Yellow");
    this.setOutput(true);
    this.setTooltip('');
  }
};

Blockly.Language.numbers_and_sensors_color_purple = {
  category: VALS,
  helpUrl: 'http://www.example.com/',
  init: function() {
    this.setColour(330);
    this.appendDummyInput()
      .appendTitle("Purple");
    this.setOutput(true);
    this.setTooltip('');
  }
};

//some sounds for frogs to hear

Blockly.Language.numbers_and_sensors_sound_chirp = {
  category: VALS,
  helpUrl: 'http://www.example.com/',
  init: function() {
    this.setColour(160);
    this.appendDummyInput()
      .appendTitle("Chirp");
    this.setOutput(true);
    this.setTooltip('');
  }
};

Blockly.Language.numbers_and_sensors_sound_croak = {
  category: VALS,
  helpUrl: 'http://www.example.com/',
  init: function() {
    this.setColour(160);
    this.appendDummyInput()
      .appendTitle("Croak");
    this.setOutput(true);
    this.setTooltip('');
  }
};

Blockly.Language.numbers_and_sensors_sound_ribbit = {
  category: VALS,
  helpUrl: 'http://www.example.com/',
  init: function() {
    this.setColour(160);
    this.appendDummyInput()
      .appendTitle("Ribbit");
    this.setOutput(true);
    this.setTooltip('');
  }
};
