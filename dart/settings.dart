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
part of ComputerHistory;


class Settings {
  
  Map<String, dynamic> _settings = new Map<String, dynamic>();

  
  static double MAX_FROG_SIZE = 1.4;
  static double MIN_FROG_SIZE = 0.2;

  
  Settings() {
    addBoolSetting("frogs-starve", false, "Can frogs starve to death?");
    //addBoolSetting("frogs-push", false, "Can frogs push each other?");
    addIntSetting("frog-lifespan", 30, 10, 60, 10, "How long can frogs live without eating?", "seconds");
    addIntSetting("max-frogs", 10, 1, 20, 1, "New frogs can hatch on a lilypad if there are fewer than this number of frogs already there.", "frogs");
  }
  
  
  addIntSetting(String name, int value, int min, int max, int step, String description, String units) {
    _settings[name] = value;

    DivElement settings = querySelector("#settings-list");
    DivElement setting = new DivElement();
    DivElement descr = new DivElement();
    DivElement ctrl = new DivElement();
    RangeInputElement input = new RangeInputElement();
    LabelElement label = new LabelElement();
    
    setting.classes.add("setting");
    descr.classes.add("setting-description");
    descr.text = description;    
    ctrl.classes.add("setting-control");
    
    input.classes.add("slider");
    input.attributes["min"] = "$min";
    input.attributes["max"] = "$max";
    input.attributes["value"] = "$value";
    input.attributes["step"] = "$step";
    
    input.id = "setting-${name}";
    input.onChange.listen((e) {
      _settings[name] = int.parse(input.value);
      setHtmlText("setting-${name}-label", "${input.value} ${units}");
    });
    input.onTouchMove.listen((e) => _sliderTouch(e, input.id, name, units));
    input.onTouchStart.listen((e) => _sliderTouch(e, input.id, name, units));
    
    label.classes.add("toggle-label");
    label.attributes["for"] = "setting-${name}";
    label.id = "setting-${name}-label";
    label.text = "${value} ${units}";

    ctrl.append(input);
    ctrl.append(label);
    setting.append(descr);
    setting.append(ctrl);
    settings.append(setting);
  }

  
  addBoolSetting(String name, bool value, String description) {
    _settings[name] = value;

    DivElement settings = querySelector("#settings-list");
    DivElement setting = new DivElement();
    DivElement descr = new DivElement();
    DivElement ctrl = new DivElement();
    RangeInputElement input = new RangeInputElement();
    LabelElement label = new LabelElement();
    
    setting.classes.add("setting");
    descr.classes.add("setting-description");
    descr.text = description;    
    ctrl.classes.add("setting-control");
    
    input.classes.add("toggle-switch");
    input.attributes["min"] = "0";
    input.attributes["max"] = "1";
    input.attributes["value"] = value ? "1" : "0";
    input.attributes["step"] = "1";
    input.id = "setting-${name}";
    input.onChange.listen((e) {
      _settings[name] = input.value == "1";
      setHtmlText("setting-${name}-label", input.value == "1" ? "YES" : "NO");
    });
    input.onTouchMove.listen((e) => _switchTouch(e, input.id, name));
    input.onTouchStart.listen((e) => _switchTouch(e, input.id, name));
    
    label.classes.add("toggle-label");
    label.attributes["for"] = "setting-${name}";
    label.id = "setting-${name}-label";
    label.text = value ? "YES" : "NO";

    ctrl.append(input);
    ctrl.append(label);
    setting.append(descr);
    setting.append(ctrl);
    settings.append(setting);
  }

  
  dynamic operator[] (String key) {
    return _settings[key];
  }
  
  
  void operator[]=(String key, var value) {
    _settings[key] = value;
  }
  
  
  bool hasSetting(String name) {
    return _settings.containsKey(name);
  }
  
  
  void removeSetting(String name) {
    _settings.remove(name);
  }
  
  
  void _switchTouch(TouchEvent tframe, String id, String name) {
    InputElement toggle = querySelector("#${id}");
    Rectangle box = toggle.getBoundingClientRect();
    num left = box.left;
    num top = box.top;
    num width = box.width;
    num tx = tframe.changedTouches[0].client.x - left;
    num ty = tframe.changedTouches[0].client.y - top;
    int min = int.parse(toggle.attributes["min"]);
    int max = int.parse(toggle.attributes["max"]);
    int step = int.parse(toggle.attributes["step"]);
    double interval = width / (max - min);
    toggle.value = "${min + (tx / interval).toInt()}";
    _settings[name] = (toggle.value == "1");
    setHtmlText("setting-${name}-label", toggle.value == "1" ? "YES" : "NO");
  }
  
  
  void _sliderTouch(TouchEvent tframe, String id, String name, String units) {
    InputElement toggle = querySelector("#${id}");
    Rectangle box = toggle.getBoundingClientRect();
    num left = box.left;
    num top = box.top;
    num width = box.width;
    num tx = tframe.changedTouches[0].client.x - left;
    num ty = tframe.changedTouches[0].client.y - top;
    int min = int.parse(toggle.attributes["min"]);
    int max = int.parse(toggle.attributes["max"]);
    int step = int.parse(toggle.attributes["step"]);
    double interval = width / (max - min);
    toggle.value = "${min + (tx / interval).toInt()}";
    _settings[name] = int.parse(toggle.value);
    setHtmlText("setting-${name}-label", "${toggle.value} ${units}");
  }
}