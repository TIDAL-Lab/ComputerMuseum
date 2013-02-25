//So far it's been my policy not to delete blockly code unless strictly necessary,
// and not to add new code to original blockly files unless necessary;
// rather, I've just commented out control constructs we've decided not to use.
// So this file corresponds to new additions to the file '_messages.js'
// in blockly/language/en

Blockly.Language.controls_repeat_forever = {
  category: 'Control Blocks',
  helpUrl: 'http://www.example.com/',
  init: function() {
    this.setColour(120);
    this.appendDummyInput()
      .appendTitle("Repeat Forever");
    this.appendStatementInput("body")
      .appendTitle("do");
    this.setPreviousStatement(true);
    this.setNextStatement(true);
    this.setTooltip('');
  }
};

//towards_seen
// lets you move towards the last sensed object.
// for example: if Quentin the frog calls (if (Sees? Red) (towards_seen (hop 10)))
// Q will look for a red frog and if he sees it, hop in its direction
Blockly.Language.numbers_and_sensors_towards_seen = {
  category: 'Control Blocks',
  helpUrl: 'http://www.example.com/',
  init: function() {
    this.setColour(120);
    this.appendDummyInput()
      .appendTitle("towards seen");
    this.appendStatementInput("NAME")
      .appendTitle("do");
    this.setPreviousStatement(true);
    this.setNextStatement(true);
    this.setTooltip('');
  }
};

//towards_heard
// towards_seen, but for hearing
Blockly.Language.numbers_and_sensors_towards_heard = {
  category: 'Control Blocks',
  helpUrl: 'http://www.example.com/',
  init: function() {
    this.setColour(120);
    this.appendDummyInput()
      .appendTitle("towards heard");
    this.appendStatementInput("NAME")
      .appendTitle("do");
    this.setPreviousStatement(true);
    this.setNextStatement(true);
    this.setTooltip('');
  }
};

