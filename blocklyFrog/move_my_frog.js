
//Move My Frog

  //Begin Block
Blockly.Language.frogs_begin = {
  category: 'Actions',
            helpUrl: 'http://www.example.com/',
            init: function() {
              this.setColour(290);
              this.appendDummyInput()
                .appendTitle("begin");
              this.setNextStatement(true);
              this.setTooltip('');
            }
};

    //Wait Block
Blockly.Language.frogs_wait = {
  category: 'Actions',
  helpUrl: 'http://www.example.com/',
  init: function() {
    this.setColour(290);
    this.appendDummyInput()
      .appendTitle("Wait");
    this.setPreviousStatement(true);
    this.setTooltip('');
  }
};

    //Hop Block
Blockly.Language.frogs_hop = {
  category: 'Actions',
  helpUrl: 'http://www.example.com/',
  init: function() {
    this.setColour(290);
    this.appendValueInput("Count")
      .setCheck(Number)
      .appendTitle("hop");
    this.setPreviousStatement(true);
    this.setNextStatement(true);
      this.setTooltip('');
    }
};
    //Turn Block
Blockly.Language.frogs_turn = {
  category: 'Actions',
  helpUrl: 'http://www.example.com/',
  init: function() {
    this.setColour(290);
    this.appendDummyInput()
      .appendTitle("Turn: ");
    this.appendValueInput("direction");
    this.setPreviousStatement(true);
    this.setNextStatement(true);
    this.setTooltip('');
  }
};
    //Chirp Block
Blockly.Language.frogs_chirp = {
  category: 'Actions',
  helpUrl: 'http://www.example.com/',
  init: function() {
    this.setColour(290);
    this.appendDummyInput()
      .appendTitle("Chirp");
    this.setPreviousStatement(true);
    this.setNextStatement(true);
    this.setTooltip('');
  }
};

    //Croak Block
Blockly.Language.frogs_croak = {
  category: 'Actions',
  helpUrl: 'http://www.example.com/',
  init: function() {
    this.setColour(290);
    this.appendDummyInput()
      .appendTitle("Croak");
    this.setPreviousStatement(true);
    this.setNextStatement(true);
    this.setTooltip('');
  }
};

    //Ribbit Block
Blockly.Language.frogs_ribbit = {
  category: 'Actions',
  helpUrl: 'http://www.example.com/',
  init: function() {
    this.setColour(290);
    this.appendDummyInput()
      .appendTitle("Ribbit");
    this.setPreviousStatement(true);
    this.setNextStatement(true);
    this.setTooltip('');
  }
};


Blockly.Language.frogs_left = {
  category: 'Actions',
  helpUrl: 'http://www.example.com/',
  init: function() {
    this.setColour(290);
    this.appendDummyInput()
      .appendTitle("Left");
    this.setOutput(true);
    this.setTooltip('');
  }
};

Blockly.Language.frogs_right = {
  category: 'Actions',
  helpUrl: 'http://www.example.com/',
  init: function() {
    this.setColour(290);
    this.appendDummyInput()
      .appendTitle("Right");
    this.setOutput(true);
    this.setTooltip('');
  }
};

Blockly.Language.frogs_around = {
  category: 'Actions',
  helpUrl: 'http://www.example.com/',
  init: function() {
    this.setColour(290);
    this.appendDummyInput()
      .appendTitle("Around");
    this.setOutput(true);
    this.setTooltip('');
  }
};
