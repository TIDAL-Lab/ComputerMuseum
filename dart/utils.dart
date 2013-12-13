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
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */
part of ComputerHistory;

Random rand = new Random();


/**
 * Is the given flag set to true in the URL query string?
 */
bool isFlagSet(String name) {
  return window.location.search.indexOf("${name}=true") > 0;
}


/**
 * Detects whether or not this is an iPad based on the user-agent string
 */
bool isIPad() {
  return window.navigator.userAgent.contains("iPad");
}


/**
 * Binds a click event to a button
 */
void bindClickEvent(String id, Function callback) {
  Element element = querySelector("#${id}");
  if (element != null) {
    if (isFlagSet("debug")) {
      element.onClick.listen(callback);
    } else {
      element.onTouchEnd.listen(callback);    
    }
  }
}


/**
 * Adds a class to a DOM element
 */
void addHtmlClass(String id, String cls) {
  Element el = querySelector("#${id}");
  if (el != null) {
    el.classes.add(cls);
  }
}


/**
 * Removes a class from a DOM element
 */
void removeHtmlClass(String id, String cls) {
  Element el = querySelector("#${id}");
  if (el != null) {
    el.classes.remove(cls);
  }
}


/**
 * Toggles a CSS class for a DOM element
 */
void toggleHtmlClass(String id, String cls) {
  Element el = querySelector("#${id}");
  if (el != null) {
    el.classes.toggle(cls);
  }
}


/**
 * Sets the inner HTML for the given DOM element 
 */
void setHtmlText(String id, String text) {
  Element el = querySelector("#${id}");
  if (el != null) {
    el.innerHtml = text;
  }
}


/**
 * Sets the inner HTML for the given DOM element 
 */
void appendHtmlText(String id, String text) {
  Element el = querySelector("#${id}");
  if (el != null) {
    el.innerHtml = el.innerHtml + text;
  }
}


/*
 * Sets the visibility state for the given DOM element
 */
void setHtmlVisibility(String id, bool visible) {
  Element el = querySelector("#${id}");
  if (el != null) {
    el.style.visibility = visible ? "visible" : "hidden";
  }
}


/*
 * Sets the opacity state for the given DOM element
 */
void setHtmlOpacity(String id, double opacity) {
  Element el = querySelector("#${id}");
  if (el != null) {
    el.style.opacity = "${opacity}";
  }
}


/*
 * Sets the background image for a DOM element
 */
void setHtmlBackground(String id, String url) {
  Element el = querySelector("#${id}");
  if (el != null) {
    el.style.backgroundImage = "url('${url}')";
  }
}


void roundRect(CanvasRenderingContext2D ctx, num x, num y, num w, num h, num r) {
  ctx.beginPath();
  ctx.moveTo(x + r, y);
  ctx.lineTo(x + w - r, y);
  ctx.quadraticCurveTo(x + w, y, x + w, y + r);
  ctx.lineTo(x + w, y + h - r);
  ctx.quadraticCurveTo(x + w, y + h, x + w - r, y + h);
  ctx.lineTo(x + r, y + h);
  ctx.quadraticCurveTo(x, y + h, x, y + h - r);
  ctx.lineTo(x, y + r);
  ctx.quadraticCurveTo(x, y, x + r, y);
  ctx.closePath();
}


void drawLineArrow(CanvasRenderingContext2D ctx,
                   num x0, num y0, num x1, num y1,
                   num width) {
  ctx.save();
  {
    ctx.beginPath();
    ctx.moveTo(x0, y0);
    ctx.lineTo(x1, y1);
    ctx.lineWidth = width;
    ctx.lineCap = 'butt';
    ctx.stroke();
    
    double theta = atan2(x1 - x0, y1 - y0);
    num x2 = x1 + sin(theta) * width * 1.2;
    num y2 = y1 + cos(theta) * width * 1.2;
    num x3 = x1 + sin(theta + PI * 0.6) * width * 1.2;
    num y3 = y1 + cos(theta + PI * 0.6) * width * 1.2;
    num x4 = x1 + sin(theta - PI * 0.6) * width * 1.2;
    num y4 = y1 + cos(theta - PI * 0.6) * width * 1.2;
    ctx.beginPath();
    ctx.moveTo(x2, y2);
    ctx.lineTo(x3, y3);
    ctx.lineTo(x1, y1);
    ctx.lineTo(x4, y4);
    ctx.closePath();
    ctx.fill();
  }
  ctx.restore();
}


void drawBubble(CanvasRenderingContext2D ctx, num x, num y, num w, num h, num radius)
{
  num r = x + w;
  num b = y + h;
  ctx.beginPath();
  ctx.lineWidth = 2;
  ctx.moveTo(x+radius, y);
  ctx.lineTo(r-radius, y);
  ctx.quadraticCurveTo(r, y, r, y+radius);
  ctx.lineTo(r, y+h-radius);
  ctx.quadraticCurveTo(r, b, r-radius, b);
  ctx.lineTo(x+radius * 2, b);
  ctx.lineTo(x+radius/2, b+10);
  ctx.lineTo(x+radius, b);
  ctx.quadraticCurveTo(x, b, x, b-radius);
  ctx.lineTo(x, y+radius);
  ctx.quadraticCurveTo(x, y, x+radius, y);
  ctx.fill();
  ctx.stroke();
}
  
  
num distance(num x0, num y0, num x1, num y1) {
  return sqrt((x1 - x0) * (x1 - x0) + (y1 - y0) * (y1 - y0));
}